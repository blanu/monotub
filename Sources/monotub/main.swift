import Foundation
import NIO

typealias Temperature = Float
typealias Humidity = Float

struct Profile
{
  name: String
  temperatureRange: TemperatureRange
  humidityRange: HumidityRange
}

struct TemperatureRange
{
  low: Temperature
  high: Temperature
  ideal: Temperature
}

struct HumidityRange
{
  low: Humidity
  high: Humidity
  ideal: Humidity
}

struct WaitTime
{
  lowDays: UInt
  highDays: UInt

  init(lowDays: UInt, highDays: UInt)
  {
    self.lowDays = lowDays
    self.highDays = highDays
  }

  init(lowWeeks: UInt, highWeeks: UInt)
  {
    self.lowDays = lowWeeks * 7
    self.highDays = highWeeks * 7
  }
}

let profiles: [Profile] =
[
  Profile()
]

private final class MonotubHandler: ChannelInboundHandler
{
  public typealias InboundIn = AddressedEnvelope<ByteBuffer>
  public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

  public func channelActive(context: ChannelHandlerContext)
  {
    print("active")
  }

  public func channelRead(context: ChannelHandlerContext, data: NIOAny)
  {
    print("read")
    let envelope = self.unwrapInboundIn(data)
    let buffer = envelope.data
    guard let bytes = buffer.getBytes(at: 0, length: buffer.readableBytes) else {return}
    let d = Data(bytes)
    guard let s = String(data: d, encoding: .utf8) else {return}
    print(s)
    print(".")
  }

  public func channelReadComplete(context: ChannelHandlerContext)
  {
    print("readComplete")
  }

  public func errorCaught(context: ChannelHandlerContext, error: Error)
  {
        print("error: ", error)
        context.close(promise: nil)
  }
}

func main(host: String, port: Int)
{
  let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  let bootstrap = DatagramBootstrap(group: group)
    .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
    .channelInitializer
    {
      channel in

      channel.pipeline.addHandler(MonotubHandler())
    }

//defer
//{
//  try! group.syncShutdownGracefully()
//}

  do
  {
    let channel = try
    {
      () -> Channel in

      return try bootstrap.bind(host: host, port: port).wait()
    }()

    print("Server started and listening on \(channel.localAddress!)")
    try channel.closeFuture.wait()
  }
  catch
  {
    print("Error bootstrapping")
  }

  print("Done.")
}

let host = "127.0.0.1"
let port = 5050

main(host: host, port: port)
