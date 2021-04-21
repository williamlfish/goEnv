package main

import (
	"fmt"
	"github.com/kelseyhightower/envconfig"
	"log"
)

type Spec struct {
	Env string `split_words:"true" default:"local"`
	CoolThing string `required:"true" split_words:"true"`
	NotRequired string `split_words:"true"`
	BoolThing bool 	`split_words:"true" default:"false"`
}

type OtherProcess struct {
	NotRequired string
	CoolThing string
}
func (o OtherProcess)Run(){
	fmt.Printf("running OtherProcess with config: Coolthing:%s, NotRequired:%s \n", o.CoolThing, o.NotRequired)
}
type App struct {
	CoolThing string
	BoolThing bool
	Runner chan bool
}

func (a App)Run(){
	fmt.Printf("running App with config: Coolthing:%s, Boolthing:%t \n", a.CoolThing, a.BoolThing)
	a.Runner<-true
}

func main(){
	var s Spec
	err := envconfig.Process("goEnv", &s)
	if err != nil{
		log.Fatal(err.Error())
	}
	runner := make(chan bool)
	app := App{
		CoolThing: s.CoolThing,
		BoolThing: s.BoolThing,
		Runner: runner,
	}
	go app.Run()
	op := OtherProcess{
		NotRequired: s.NotRequired,
		CoolThing: s.CoolThing,
	}
	op.Run()
	select {
		case <-runner:
			fmt.Println("Done")
			close(runner)
	}

}