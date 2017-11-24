package main

import (
	"strings"

	log "github.com/sirupsen/logrus"
)

// codebeat:disable[TOO_MANY_IVARS]

// Planet contains all Informations of one server
type Planet struct {
	id           string
	name         string
	user         string
	host         string
	planetType   string
	valid        bool
	outputStruct *StructuredOuput
}

// StructuredOuput ...
type StructuredOuput struct {
	planet   string
	output   string
	position int
	errored  bool
	errors   map[string]string
}

// codebeat:enable[TOO_MANY_IVARS]

func (planet *Planet) execute(opts *Opts) {

	sourcepath := strings.Split(opts.Source, "/")
	filename := sourcepath[len(sourcepath)-1]
	src := strings.Join([]string{"$HOME", filename}, "/")
	var dest string
	if strings.HasSuffix(opts.Dest, "/") {
		dest = strings.Join([]string{opts.Dest, filename}, "/")
	} else {
		dest = opts.Dest
	}

	planet.upload(opts, src, dest)

	if opts.Mode != "" {
		planet.chmod(opts, dest)
	}
	if opts.Owner != "" {
		planet.chown(opts, dest)
	}
}

func (planet *Planet) upload(opts *Opts, src string, dest string) {
	uploadFile(planet, opts)

	fullInfo := []string{"mv", src, dest}
	moveCommand := strings.Join(fullInfo, " ")
	execCommand(moveCommand, planet, opts)
}

func (planet *Planet) chmod(opts *Opts, file string) {
	modCommand := strings.Join([]string{"chmod", opts.Mode, file}, " ")
	execCommand(modCommand, planet, opts)
}

func (planet *Planet) chown(opts *Opts, file string) {
	ownCommand := strings.Join([]string{"chown", opts.Owner, file}, " ")
	execCommand(ownCommand, planet, opts)
}

func (planet *Planet) planetInfo(opts *Opts) {
	log.Debugln("###planet.execute-->execcommand###")
	log.Debugln("planet.user: %s", planet.user)
	log.Debugln("planet.host: %s", planet.host)
	log.Debugln("planet.outputStruct: %v", planet.outputStruct)
	log.Debugln("opts: %v\n", opts)
	log.Debugln("###planet.execute-->execcommand###")
}
