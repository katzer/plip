package main

import (
	"fmt"
	"os"
	"path"
	"strings"

	log "github.com/sirupsen/logrus"
)

func makeLoadCommand(command string, opts *Opts) string {
	if opts.Load {
		log.Debugf("profile load has been applied")
		return fmt.Sprintf(`sh -lc "echo -----APPPLANT-ORBIT----- && %s "`, command)
	}
	return command
}

func cleanProfileLoadedOutput(output string, opts *Opts) string {
	if opts.Load {
		splitOut := strings.Split(output, "-----APPPLANT-ORBIT-----\n")
		log.Debugf("cleaned part: %s", splitOut[0])
		return splitOut[len(splitOut)-1]
	}
	return output
}

func makeDir(name string) {
	tempdir := path.Join(os.Getenv("ORBIT_HOME"), name)
	err := os.MkdirAll(tempdir, 0700)
	if err != nil {
		log.Error(err)
	}
}
