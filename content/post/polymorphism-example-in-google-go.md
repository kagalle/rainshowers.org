+++
Description = ""
Tags = [
]
date = "2010-10-30"
title = "Polymorphism example in Google Go"

+++

I wrote a bare-bones example in Google Go to excersize embedding, poloymorphism and interfaces in Go. It does nearly nothing, but it works as expected. It has the advantage of being very small.<!--more-->

It has one interface, "Communicate", with the contract that it knows how to "Talk". Two objects implement that interface, Cat and Dog. Both Cat and Dog embed the Pet object, which contains a name field with getters and setters for name.

In the main function, a Cat and Dog are created and assigned to Communicate variables. When each of these are told to Talk() they do it correctly (based on their actual types).

```go
package main

import "fmt"

type Communicate interface {
	Talk(words string)
}
type Pet struct {
	name string
}
func (p *Pet) SetName (name string) {
	p.name = name
}
func (p *Pet) GetName () string {
	return p.name
}
type Cat struct {
	Pet
}
func NewCat (name string) *Cat {
	c := new(Cat)
	c.SetName(name)
	return c
}
func (c *Cat) Talk(words string) {
	fmt.Printf("Cat named " + c.GetName() + " says " + words + "\n");
}
type Dog struct {
	Pet
}
func NewDog (name string) *Dog {
	d := new(Dog)
	d.SetName(name)
	return d
}
func (d *Dog) Talk(words string) {
	fmt.Printf("Dog named " + d.GetName() + " says " + words + "\n");
}

func DoTalk(x Communicate, words string) {
	x.Talk(words)
}
func main() {
	var c, d Communicate
	c = NewCat("KC")
	d = NewDog("Red")
	c.Talk("meow")
	d.Talk("woof")
}
```
Output is:
```text
Cat named KC says meow
Dog named Red says woof
```