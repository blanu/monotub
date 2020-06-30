#!/usr/bin/env python3
# coding=utf-8

import sys
import time
import socket
import qwiic_bme280
import smbus
from VEML6030py.veml6030 import VEML6030

def main():
  print("monotubs.com - SmartTub 0.1")

  if len(sys.argv) < 2:
    print("Usage: monotub.py [tubname]")
    return

  tubname = sys.argv[1]

  destination = ("127.0.0.1", 5050)

  bme280 = qwiic_bme280.QwiicBme280()

  if bme280.connected == False:
    print('Humidity and temperature sensor not connected')
    return

  bus = smbus.SMBus(1)  # For Raspberry Pi 
  light = VEML6030(bus)

  database = open('monotub.csv', 'a+')

  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

  bme280.begin()

  while True:
    timestamp = int(time.time())
    rh = int(bme280.humidity)
    tc = bme280.temperature_celsius
    lux = light.read_light()

    print("Humidity:\t%.3f%%" % rh)
    print("Temperature:\t%.2fC" % tc)
    print("Ambient light:\t%.2f lux" % lux)
    print("")

    message = f"{tubname},{timestamp},{rh},{tc},{lux}"
    database.write(message+"\n")

    bs = bytes(message, "utf-8")
    sock.sendto(bs, destination)

    time.sleep(1)

if __name__ == '__main__':
  try:
    main()
  except (KeyboardInterrupt, SystemExit) as exErr:
    print('Done.')
