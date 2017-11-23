package main

import (
	"fmt"
	"os"
	"strings"
)

// codebeat:disable[TOO_MANY_IVARS]

// Opts structure for holding commandline arguments
type Opts struct {
	Debug   bool     `json:"debug"`
	Help    bool     `json:"help"`
	Load    bool     `json:"load"`
	Version bool     `json:"version"`
	Mode    string   `json:"mode"`
	Owner   string   `json:"owner"`
	Source  string   `json:"source"`
	Dest    string   `json:"destination"`
	Planets []string `json:"planets"`
}

// codebeat:enable[TOO_MANY_IVARS]

func (opts *Opts) String() string {
	template := `opts : {
	Debug: %t
	Help: %t
	Load: %t
	Pretty: %t
	Version: %t
	MaxToKeep: %d
	Command: %s
	ScriptName: %s
	Template : %s
	Planets: %v
}
`

	return fmt.Sprintf(template,
		opts.Debug,
		opts.Help,
		opts.Load,
		opts.Version,
		opts.Planets)
}

func (opts *Opts) validate() {
	opts.checkForInvalidIds()
}

func (opts *Opts) checkForInvalidIds() {
	for _, id := range opts.Planets {
		// Check if any flags were given after planet ids, if yes stop the app
		if strings.HasPrefix(id, "-") {
			fmt.Fprintf(os.Stderr, "Unknown target: %s", id)
			os.Exit(1)
		}
	}
}
