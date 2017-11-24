package main

import (
	"fmt"

	log "github.com/sirupsen/logrus"
	"gopkg.in/appPlant/easyssh.v0"
)

func execCommand(command string, planet *Planet, opts *Opts) error {
	log.Debugf("function: execCommand")
	log.Debugf("user, host : %s %s", planet.user, planet.host)
	keyPath := getKeyPath()
	ssh := &easyssh.MakeConfig{
		User:   planet.user,
		Server: planet.host,
		Key:    keyPath,
		Port:   "22",
	}
	cmd := makeLoadCommand(command, opts)
	log.Debugf("complete command %s", cmd)
	// Call Run method with command you want to run on remote server.
	out, err := ssh.Run(cmd)
	// Handle errors
	if err != nil {
		message := fmt.Sprintf("Command: %s", cmd)
		errorString := fmt.Sprintf("%s \nAdditional Info: %s \n", err, message)
		log.Warn(errorString)
		planet.outputStruct.output = fmt.Sprintf("%s%s", planet.outputStruct.output, errorString)
		planet.outputStruct.errors["output"] = fmt.Sprintf("%s%s", planet.outputStruct.output, errorString)
		planet.outputStruct.errored = true
		return err
	}
	out = cleanProfileLoadedOutput(out, opts)
	planet.outputStruct.output += out
	return nil
}

func uploadFile(planet *Planet, opts *Opts) error {
	keyPath := getKeyPath()

	ssh := &easyssh.MakeConfig{
		User:   planet.user,
		Server: planet.host,
		Key:    keyPath,
		Port:   "22",
	}

	//scriptPath := getScriptPath(opts)

	// Call Scp method with file you want to upload to remote server.
	err := ssh.Scp(opts.Source)

	// Handle errors
	if err != nil {
		message := fmt.Sprintf("called from uploadFile. Keypath: %s", keyPath)
		errorString := fmt.Sprintf("%s\nAddInf: %s\n", err, message)
		log.Warn(errorString)
		planet.outputStruct.output = fmt.Sprintf("%s\n%s\n", planet.outputStruct.output, errorString)
		planet.outputStruct.errors["output"] = fmt.Sprintf("%s\n%s\n", planet.outputStruct.output, errorString)
		planet.outputStruct.errored = true
		return err
	}
	return nil
}
