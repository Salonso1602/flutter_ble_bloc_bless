"""
Example for a BLE 4.0 Server
"""
from random import randint
import sys
import logging
import asyncio
import threading
import pyuac

from typing import Any, Union

from bless import (  # type: ignore
    BlessServer,
    BlessGATTCharacteristic,
    GATTCharacteristicProperties,
    GATTAttributePermissions,
)

if not pyuac.isUserAdmin():
    print("Re-launching as admin!")
    pyuac.runAsAdmin()
    exit(0)

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(name=__name__)
server = None

# NOTE: Some systems require different synchronization methods.
trigger: Union[asyncio.Event, threading.Event]
if sys.platform in ["darwin", "win32"]:
    trigger = threading.Event()
else:
    trigger = asyncio.Event()


def read_request(characteristic: BlessGATTCharacteristic, **kwargs) -> bytearray:
    logger.debug(f"Reading {characteristic.value}")
    return characteristic.value


def write_request(characteristic: BlessGATTCharacteristic, value: Any, **kwargs):
    global server
    characteristic.value = value
    logger.debug(f"Char value set to {characteristic.value}")
    if characteristic.value == b"\x0a":
        def set_rand_val():
            characteristic.value = [randint(1,255)]
            logger.debug("TIMER DONE")
            server.update_value(
                "AAAAAAAA-AD5B-474E-940D-16F1FBE7E8CD",
                "BBBBBBBB-3ED8-46E5-B4F9-D64E2FEC021B",
            ) # Notify that the characteristic was updated
        threading.Timer(5, function=set_rand_val).start()
        logger.debug("NICE")
    if characteristic.value == b"\x0f":
        logger.debug("NICE")
        trigger.set()

async def run(loop):
    global server
    trigger.clear()
    # Instantiate the server
    my_service_name = "Test BLE"
    server = BlessServer(name=my_service_name, loop=loop, name_overwrite=True)
    server.read_request_func = read_request
    server.write_request_func = write_request

    # Add Service
    my_service_uuid = "AAAAAAAA-AD5B-474E-940D-16F1FBE7E8CD"
    await server.add_new_service(my_service_uuid)

    # Add a Characteristic to the service
    my_char_uuid = "BBBBBBBB-3ED8-46E5-B4F9-D64E2FEC021B"
    char_flags = (
        GATTCharacteristicProperties.read
        | GATTCharacteristicProperties.write
        | GATTCharacteristicProperties.notify
    )
    permissions = GATTAttributePermissions.readable | GATTAttributePermissions.writeable
    await server.add_new_characteristic(
        my_service_uuid, my_char_uuid, char_flags, None, permissions
    )

    logger.debug(server.get_characteristic(my_char_uuid))
    await server.start()
    logger.debug("Advertising")
    logger.info(f"Write '0xF' to the advertised characteristic: {my_char_uuid}")
    if trigger.__module__ == "threading":
        trigger.wait()
    else:
        await trigger.wait()

    await asyncio.sleep(2)
    logger.debug("Updating")
    server.get_characteristic(my_char_uuid)
    server.update_value(my_service_uuid, my_char_uuid)
    await asyncio.sleep(5)
    await server.stop()


loop = asyncio.get_event_loop()
loop.run_until_complete(run(loop))