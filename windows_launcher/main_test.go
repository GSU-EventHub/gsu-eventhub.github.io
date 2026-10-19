package main

import (
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestServesBundleAndHealth(t *testing.T) {
	root := t.TempDir()
	_ = os.WriteFile(filepath.Join(root, "index.html"), []byte("GSU test bundle"), 0600)
	for path, want := range map[string]string{"/": "GSU test bundle", "/__eventhub_health": marker} {
		w := httptest.NewRecorder()
		handler(root).ServeHTTP(w, httptest.NewRequest("GET", path, nil))
		if w.Code != 200 || !strings.Contains(w.Body.String(), want) {
			t.Fatalf("%s: %d %s", path, w.Code, w.Body.String())
		}
	}
	w := httptest.NewRecorder()
	handler(root).ServeHTTP(w, httptest.NewRequest("POST", "/", nil))
	if w.Code != 405 {
		t.Fatal(w.Code)
	}
}
