package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/fatih/color"
	log "github.com/sirupsen/logrus"
)

var help, debug, load, _version bool
var own, mode string

func main() {
	validateArgsCount()
	opts := parseOptions()
	validateEnv()
	opts.validate()

	setupDirs()

	log.Debug("Started with args: %v", os.Args)
	log.Debug(&opts)
	exec := makeExecutor(&opts)
	exec.execMain(&opts)
	//if len(jobFile) == 0 {
	printUnformatted(exec.planets, color.Output)
	handleExitCode(exec.planets)
	return
	//}
	// options := map[string]string{}
	// options["job_name"] = path.Base(jobFile)
	// options["orbit_home"] = os.Getenv("ORBIT_HOME")
	// options["output"] = "reports"
	//
	// createJSONReport(options, exec.planets, &opts)
}

// if there were any errors during the execution of command or scripts
// on any of the planets given as parameter, the exit code is set to non zero
// in case other programs rely on the exit code.
func handleExitCode(planets []Planet) {
	for _, entry := range planets {
		structuralError := entry.outputStruct == nil
		executionFailure := entry.outputStruct.errored
		if structuralError || executionFailure {
			os.Exit(1)
		}
	}
}

func makeExecutor(opts *Opts) Executor {
	log.Debugf("Function: makeExecutor")
	executor := Executor{}
	planets := parseConnectionDetails(opts.Planets)
	executor.planets = planets
	log.Debugf("executor: %s", executor)
	return executor
}

func isValidPlanet(planet Planet) bool {
	ok := isSupported(planet.planetType)
	if !ok {
		planet.outputStruct.output += "Planettype not supported\n"
	}
	// TODO: since we know what kind of action is attempted on this server
	// we could check if the action is permitted on the current planet and
	// if not mark it as not valid
	return ok
}

func printUsage() {
	usage := `plip - Planet Impact Probe

usage: plip [options...] <sourcepath> <destinationpath> <planets>...
Options:
-own="<owner[:group]>"    Execute script and return result
-mod="<mode>"      	      Execute script and return result
-l    Load bash profiles on server
-h    Display this help text
-v    Show version number
-d    Show extended debug informations, set logging level to debug
`
	fmt.Println(usage)
	os.Exit(0)
}

func parseOptions() Opts {
	flag.BoolVar(&help, "h", false, "help")
	flag.BoolVar(&debug, "d", false, "verbose")
	flag.BoolVar(&load, "l", false, "ssh profile loading")
	flag.BoolVar(&_version, "v", false, "version")
	flag.StringVar(&own, "own", "", "user (and group) to be made owner of this file")
	flag.StringVar(&mode, "mod", "", "filemode to be used for this file")
	flag.Parse()

	tail := flag.Args()
	if len(tail) < 3 {
		printUsage()
	}

	opts := Opts{
		Help:    help,
		Debug:   debug,
		Load:    load,
		Version: _version,
		Mode:    mode,
		Owner:   own,
		Source:  tail[0],
		Dest:    tail[1],
		Planets: tail[2:],
	}

	postProcessing(&opts)

	return opts
}

func validateArgsCount() {
	// if opts.Version {
	// 	printVersion()
	// 	os.Exit(0)
	// }
	tooFew := len(os.Args) < 4

	if tooFew {
		printUsage()
	}
}

func validateEnv() {
	if os.Getenv("ORBIT_HOME") == "" {
		log.Fatal("ORBIT_HOME not set!")
	}
}

func postProcessing(opts *Opts) {
}
func setupDirs() {
	makeDir("tmp")
	makeDir("jobs")
	makeDir("reports")
}
