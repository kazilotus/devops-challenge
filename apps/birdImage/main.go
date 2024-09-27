package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
)

type Urls struct {
	Thumb string
}

type Links struct {
	Urls Urls
}

type ImageResponse struct {
	Results []Links
}

type Bird struct {
	Image string
}

func defaultImage() string {
	defaultImageURL := os.Getenv("DEFAULT_IMAGE_URL")
	if defaultImageURL == "" {
		defaultImageURL = "https://www.pokemonmillennium.net/wp-content/uploads/2015/11/missingno.png"
	}
	return defaultImageURL
}

func getBirdImage(birdName string) string {
	apiURL := os.Getenv("UNSPLASH_API_URL")
	clientID := os.Getenv("UNSPLASH_CLIENT_ID")
	if apiURL == "" {
		apiURL = "https://api.unsplash.com/search/photos"
	}
	if clientID == "" {
		fmt.Println("Error: UNSPLASH_CLIENT_ID not set")
		return defaultImage()
	}

	query := fmt.Sprintf(
		"%s?page=1&query=%s&client_id=%s&per_page=1",
		apiURL,
		url.QueryEscape(birdName),
		clientID,
	)
	res, err := http.Get(query)
	if err != nil {
		fmt.Printf("Error reading image API: %s\n", err)
		return defaultImage()
	}
	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Printf("Error parsing image API response: %s\n", err)
		return defaultImage()
	}

	var response ImageResponse
	err = json.Unmarshal(body, &response)
	if err != nil || len(response.Results) == 0 {
		fmt.Printf("Error unmarshalling bird image: %s", err)
		return defaultImage()
	}

	return response.Results[0].Urls.Thumb
}


func bird(w http.ResponseWriter, r *http.Request) {
	var buffer bytes.Buffer
	birdName := r.URL.Query().Get("birdName")
	if birdName == "" {
		json.NewEncoder(&buffer).Encode(defaultImage())
	} else {
		json.NewEncoder(&buffer).Encode(getBirdImage(birdName))
	}
	io.WriteString(w, buffer.String())
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "4200"
	}

	http.HandleFunc("/", bird)
	http.ListenAndServe(":"+port, nil)
}
