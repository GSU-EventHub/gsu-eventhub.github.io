// Serve the compiled app at a fixed loopback origin so storage survives relaunches.
package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"time"
)

const address = "127.0.0.1:47831"
const marker = "GSU-EventHub-1"

func handler(root string) http.Handler {
	files := http.FileServer(http.Dir(root))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		if r.URL.Path == "/__eventhub_health" {
			w.Header().Set("Content-Type", "text/plain")
			fmt.Fprint(w, marker)
			return
		}
		w.Header().Set("X-Content-Type-Options", "nosniff")
		w.Header().Set("Cache-Control", "no-cache")
		files.ServeHTTP(w, r)
	})
}
func openBrowser() {
	url := "http://" + address + "/"
	if runtime.GOOS == "windows" {
		_ = exec.Command("rundll32", "url.dll,FileProtocolHandler", url).Start()
	}
	fmt.Println("Open", url, "if the browser did not open automatically.")
}
func main() {
	noBrowser := flag.Bool("no-browser", false, "serve without opening a browser (for automated checks)")
	flag.Parse()
	executable, err := os.Executable()
	if err != nil {
		log.Fatal(err)
	}
	root := filepath.Join(filepath.Dir(executable), "web")
	if _, err := os.Stat(filepath.Join(root, "index.html")); err != nil {
		log.Fatal("The bundled web folder is missing. Extract the entire ZIP before launching. ", err)
	}
	listener, err := net.Listen("tcp", address)
	if err != nil {
		log.Fatal("Cannot start GSU EventHub. Close another launcher or resolve the port conflict, then retry. ", err)
	}
	fmt.Println("GSU EventHub is running. Keep this window open; close it to stop the app.")
	if !*noBrowser {
		openBrowser()
	}
	server := &http.Server{Handler: handler(root), ReadHeaderTimeout: 5 * time.Second}
	log.Fatal(server.Serve(listener))
}
