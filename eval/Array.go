package main

import "fmt"

type Token struct {
	value string
	typ   string
}

func T(arr *[]Token) {
	*arr = append(*arr, Token{value: "a", typ: "string"})

	fmt.Println((*arr)[0].value)
}

func T2(arr []Token) {
	arr = append(arr, Token{value: "a", typ: "string"})
}

func main() {
	arr := []Token{}
	T(&arr)
	T2(arr)
	println(len(arr))
}
