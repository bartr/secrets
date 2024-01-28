package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

// default values
var uri = "/secrets/"
var port = 8080
var logResults = false

// version gets set in the build / dockerfile
var Version = "dev"

// main app
func main() {

	parseCommandLine()

	setupHandlers()

	displayConfig()

	// run the web server
	if err := http.ListenAndServe(":"+strconv.Itoa(port), nil); err != nil {
		log.Fatal(err)
	}
}

// setup handlers
func setupHandlers() {
	// handle /secrets/
	http.Handle(uri, http.HandlerFunc(secretsHandler))

	// handle /healthz
	http.Handle("/healthz", http.HandlerFunc(healthzHandler))

	// handle /readyz
	http.Handle("/readyz", http.HandlerFunc(readyzHandler))

	// handle /version
	http.Handle("/version", http.HandlerFunc(versionHandler))

	// handle all other URIs
	http.Handle("/", http.HandlerFunc(rootHandler))
}

// display config
func displayConfig() {
	log.Println("Version:    ", Version)
	log.Println("URI:        ", uri)
	log.Println("Port:       ", port)
	log.Println("Log Results ", logResults)
}

// parseCommandLine
func parseCommandLine() {
	// parse flags
	u := flag.String("u", uri, "URI to listen on")
	p := flag.Int("p", port, "port to listen on")
	l := flag.Bool("log", logResults, "log incoming requests")
	v := flag.Bool("v", false, "display version")

	flag.Parse()

	// add  trailing /
	if !strings.HasSuffix(*u, "/") {
		*u += "/"
	}

	// check URI
	if !strings.HasPrefix(*u, "/") {
		flag.Usage()
		log.Fatal("URI must start with /")
	}

	if *u == "/" {
		flag.Usage()
		log.Fatal("URI cannot be '/'")
	}

	// check port
	if *p <= 0 || *p >= 64*1024 {
		flag.Usage()
		log.Fatal("invalid port")
	}

	// display version and exit
	if *v {
		fmt.Println(Version)
		os.Exit(0)
	}

	// set variables to args (or defaults)
	uri = *u
	port = *p
	logResults = *l
}

// very basic logging
func logToConsole(code int, path string, duration time.Duration) {
	if logResults {
		log.Println(code, "\t", duration, "\t", path)
	}
}

// handle /  /index.*  and /default.*
func rootHandler(w http.ResponseWriter, r *http.Request) {
	// start the request timer
	start := time.Now()

	if r.URL.Path == "/" || strings.HasPrefix(r.URL.Path, "/index.") || strings.HasPrefix(r.URL.Path, "/default.") {

		http.Redirect(w, r, uri, http.StatusMovedPermanently)

		logToConsole(http.StatusMovedPermanently, r.URL.Path, time.Since(start))
	} else {
		logToConsole(http.StatusNotFound, r.URL.Path, time.Since(start))
		w.WriteHeader(http.StatusNotFound)
	}
}

// handle /healthz
func healthzHandler(w http.ResponseWriter, r *http.Request) {
	// start the request timer
	start := time.Now()

	w.Header().Add("Cache-Control", "no-cache")
	fmt.Fprintf(w, "Pass\n")

	logToConsole(http.StatusOK, r.URL.Path, time.Since(start))
}

// handle /readyz
func readyzHandler(w http.ResponseWriter, r *http.Request) {
	// start the request timer
	start := time.Now()

	w.Header().Add("Cache-Control", "no-cache")
	fmt.Fprintf(w, "Ready\n")

	logToConsole(http.StatusOK, r.URL.Path, time.Since(start))
}

// handle /version
func versionHandler(w http.ResponseWriter, r *http.Request) {
	// start the request timer
	start := time.Now()

	w.Header().Add("Cache-Control", "no-cache")
	fmt.Fprintf(w, Version+"\n")

	logToConsole(http.StatusOK, r.URL.Path, time.Since(start))
}

// handle /secrets (or -u)
func secretsHandler(w http.ResponseWriter, r *http.Request) {
	// start the request timer
	start := time.Now()

	// set no-cache
	w.Header().Add("Cache-Control", "no-cache")

	// Specify the directory path
	dirPath := "secrets"

	// Check if the directory exists
	if _, err := os.Stat(dirPath); os.IsNotExist(err) {
		fmt.Fprintf(w, "Directory does not exist")
		logToConsole(500, r.URL.Path, time.Since(start))
		return
	}

	// Read files in the directory
	fileInfos, err := ioutil.ReadDir(dirPath)
	if err != nil {
		fmt.Fprintf(w, "Error reading directory:", err)
		logToConsole(500, r.URL.Path, time.Since(start))
		return
	}

	// Iterate over each file in the directory
	for _, fileInfo := range fileInfos {
		filePath := filepath.Join(dirPath, fileInfo.Name())

		// Read the contents of the file
		fileContent, err := ioutil.ReadFile(filePath)
		if err != nil {
			fmt.Fprintf(w, "Error reading file %s: %v\n", fileInfo.Name(), err)
			logToConsole(500, r.URL.Path, time.Since(start))
			continue
		}

		// Print the file name, a colon, a space, and the file contents
		fmt.Fprintf(w, "%s: %s\n", fileInfo.Name(), fileContent)
	}

	logToConsole(http.StatusOK, r.URL.Path, time.Since(start))
}
