# HTTPAsm

_The world's crappiest webserver and TCP/IP stack written in MIPS assembly._

## Features

* 100% MIPS assembly.
* Runs on GXemul.
* Serves a small static web page with `GET` method.
* Server can be remotely shut down with `POST` method.
* Works with Google Chrome.
* Requires no network configuration. It assumes all IP addresses and TCP ports.
* Responds to ping.
* Contains a terribly hacky stateless TCP/IP implementation.
* Difficult to read.

## Build the project

1. Use Ubuntu 16.10 64b.
2. Install `gcc-5-mips-linux-gnu`.
3. Run `./build.sh`.

## Run the project

You will need [GXemul with TAP network interface](https://github.com/danielkasza/gxemul-tap).
A binary is provided for 64b Ubuntu 16.10 for your convenience.

1. Run `sudo ./run.sh` to run the program on using the prebuilt `gxemul` binary.
2. Configure the new network interface. This will most likely be called `tap0`. You can assign any IP address to this interface. I usually run `sudo ifconfig tap0 192.168.81.1`
3. Visit the page in your browser. You just have to pick an IP from the assigned subnet. If you used the command above, 192.168.81.2 will work. (or 192.168.81.3,4,5,6,...)

## How does this work?

Well, you could read the code and try to understand it. I have to warn you though: it is extremely ugly.
It also does not look like what you would expect from a MIPS assembly program.

A few notable things:
* The stack is not used.
* There are no variables.
* The entire server is a single big loop.
* No state is preserved between received Ethernet frames.
* The TCP implementation is stateless, so the HTTP requests and responses have to fit in a single Ethernet frame.
* You could crash the server by sending it invalid TCP/IP frames, but you probably have something better to do anyway.
* This works mostly because network stacks and browsers are well written and forgiving. It is otherwise an awful example for TCP/IP and HTTP.

## Why?

* Why not?
* I wanted to demonstrate how little code is required to make a network stack that works. (sort of)
