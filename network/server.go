package main

import (
	"fmt"
	"net"
)

func main() {
	ln, err := net.Listen("tcp", "127.0.0.1:8080")

	if err != nil {
		fmt.Println(err)
		return
	}

	defer ln.Close()

	for {
		conn, err := ln.Accept()
		if err != nil {
			continue
		}

		fmt.Println(conn.RemoteAddr())

		buf := make([]byte, 1024)

		n, _ := conn.Read(buf)

		fmt.Println(string(buf[:n]))
	}
}
