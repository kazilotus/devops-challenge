package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"math/rand/v2"
	"net/http"
	"net/url"
	"os"
)

type Bird struct {
	Name        string
	Description string
	Image       string
}

func defaultBird(err error) Bird {
	defaultImageURL := os.Getenv("DEFAULT_IMAGE_URL")
	if defaultImageURL == "" {
		defaultImageURL = "https://www.pokemonmillennium.net/wp-content/uploads/2015/11/missingno.png"
	}
	return Bird{
		Name:        "Bird in disguise",
		Description: fmt.Sprintf("This bird is in disguise because: %s", err),
		Image:       defaultImageURL,
	}
}

func getBirdImage(birdName string) (string, error) {
	birdImageAPIURL := os.Getenv("BIRD_IMAGE_API_URL")
	if birdImageAPIURL == "" {
		birdImageAPIURL = "http://localhost:4200"
	}
	res, err := http.Get(fmt.Sprintf("%s?birdName=%s", birdImageAPIURL, url.QueryEscape(birdName)))
	if err != nil {
		return "", err
	}
	body, err := io.ReadAll(res.Body)
	if err != nil {
		return "", err
	}

	// Unquote the response to avoid double escaping
	var imgURL string
	err = json.Unmarshal(body, &imgURL)
	if err != nil {
		return "", err
	}

	return imgURL, nil
}

func getBirdFactoid() Bird {
	birdAPIBaseURL := os.Getenv("BIRD_API_BASE_URL")
	if birdAPIBaseURL == "" {
		birdAPIBaseURL = "https://freetestapi.com/api/v1/birds/"
	}
	res, err := http.Get(fmt.Sprintf("%s%d", birdAPIBaseURL, rand.IntN(50)))
	if err != nil {
		fmt.Printf("Error reading bird API: %s\n", err)
		return defaultBird(err)
	}
	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Printf("Error parsing bird API response: %s\n", err)
		return defaultBird(err)
	}
	var bird Bird
	err = json.Unmarshal(body, &bird)
	if err != nil {
		fmt.Printf("Error unmarshalling bird: %s", err)
		return defaultBird(err)
	}
	birdImage, err := getBirdImage(bird.Name)
	if err != nil {
		fmt.Printf("Error in getting bird image: %s\n", err)
		return defaultBird(err)
	}
	bird.Image = birdImage
	return bird
}

func bird(w http.ResponseWriter, r *http.Request) {
	var buffer bytes.Buffer
	json.NewEncoder(&buffer).Encode(getBirdFactoid())
	io.WriteString(w, buffer.String())
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "4201"
	}
	http.HandleFunc("/", bird)
	http.ListenAndServe(":"+port, nil)
}
