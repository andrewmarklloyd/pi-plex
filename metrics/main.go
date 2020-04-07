package main

import (
    "bytes"
    "os"
    "strings"

    "fmt"
    "io/ioutil"
    "net/http"
    "os/exec"
)

var devices = []string{"/dev/root", "/dev/sda2"}
var url = os.Getenv("API_URL")
var apiKey = os.Getenv("API_KEY")

func main() {
    metrics := getMetrics()
    sendUsage(fmt.Sprintf(`{"x-api-key":"%s", "metrics": %s}`, apiKey, metrics))
}

func sendUsage(postData string) {
    var jsonStr = []byte(postData)
    req, _ := http.NewRequest("POST", url, bytes.NewBuffer(jsonStr))
    req.Header.Set("Content-Type", "application/json")

    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        panic(err)
    }
    defer resp.Body.Close()

    body, _ := ioutil.ReadAll(resp.Body)
    fmt.Println(string(body))
}

func getMetrics() string {
    metrics := `{`
    out, _ := exec.Command("df", "-h").Output()

    outlines := strings.Split(string(out), "\n")
    l := len(outlines)
    numMetrics := 0
    for _, line := range outlines[1 : l-1] {
        parsedLine := strings.Fields(line)
        if contains(devices, parsedLine[0]) {
            metrics += fmt.Sprintf(`"%s":"%s"`, parsedLine[0], parsedLine[4])
            if numMetrics != 1 {
                metrics += ","
            }
            numMetrics++
        }
    }
    metrics += "}"
    return metrics
}

func contains(arr []string, str string) bool {
    for _, a := range arr {
        if a == str {
            return true
        }
    }
    return false
}

