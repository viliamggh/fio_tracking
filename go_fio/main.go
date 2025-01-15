package main

import (
	"fmt"
	"io"
	"net/http"
)

const startDate = "2024-12-01"
const endDate = "2025-01-12"
const format = "json"
const token = "xxxx"

func main() {
	// fmt.Println("hello")

	data, err := FetchTransactionData(token, startDate, endDate, format)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return
	}

	fmt.Printf("Response Data: %s\n", string(data))
}

// package handlers

// func TransactionHandler(w http.ResponseWriter, r *http.Request) {
// 	// Parse start-date and end-date from query parameters
// 	startDate := r.URL.Query().Get("start-date")
// 	endDate := r.URL.Query().Get("end-date")

// 	if startDate == "" || endDate == "" {
// 		http.Error(w, "start-date and end-date are required", http.StatusBadRequest)
// 		return
// 	}

// 	// Fetch data from REST API
// 	apiURL := os.Getenv("API_BASE_URL")
// 	data, err := FetchTransactionData(apiURL, startDate, endDate)
// 	if err != nil {
// 		http.Error(w, fmt.Sprintf("Error fetching data: %v", err), http.StatusInternalServerError)
// 		return
// 	}

// 	// Save JSON to Azure Blob Storage
// 	containerName := os.Getenv("BLOB_CONTAINER_NAME")
// 	blobName := fmt.Sprintf("transactions_%s_%s.json", startDate, endDate)
// 	err = UploadToBlobStorage(containerName, blobName, data)
// 	if err != nil {
// 		http.Error(w, fmt.Sprintf("Error saving to blob: %v", err), http.StatusInternalServerError)
// 		return
// 	}

// 	w.WriteHeader(http.StatusOK)
// 	w.Write([]byte("Transaction data successfully stored in Azure Blob Storage"))
// }

//

func FetchTransactionData(token, startDate, endDate, format string) ([]byte, error) {

	fullURL := fmt.Sprintf("https://fioapi.fio.cz/v1/rest/periods/%s/%s/%s/transactions.%s", token, startDate, endDate, format)
	fmt.Printf("Making API call to: %s\n", fullURL)

	// Make GET request
	resp, err := http.Get(fullURL)
	if err != nil {
		return nil, fmt.Errorf("failed to call API: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API returned non-200 status: %d, Response: %s", resp.StatusCode, string(body))
	}

	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read API response: %w", err)
	}

	return body, nil
}

// func UploadToBlobStorage(containerName, blobName string, data []byte) error {
// 	accountName := os.Getenv("AZURE_STORAGE_ACCOUNT")
// 	accountKey := os.Getenv("AZURE_STORAGE_ACCESS_KEY")
// 	if accountName == "" || accountKey == "" {
// 		return fmt.Errorf("Azure Storage account name or key is not set")
// 	}

// 	// Create a shared key credential
// 	cred, err := azblob.NewSharedKeyCredential(accountName, accountKey)
// 	if err != nil {
// 		return fmt.Errorf("failed to create credential: %w", err)
// 	}

// 	// Create a blob service client
// 	serviceURL := fmt.Sprintf("https://%s.blob.core.windows.net/", accountName)
// 	client, err := azblob.NewClientWithSharedKeyCredential(serviceURL, cred, nil)
// 	if err != nil {
// 		return fmt.Errorf("failed to create blob service client: %w", err)
// 	}

// 	// Get container client
// 	containerClient := client.NewContainerClient(containerName)

// 	// Upload blob
// 	blobClient := containerClient.NewBlobClient(blobName)
// 	_, err = blobClient.Upload(context.Background(), bytes.NewReader(data), nil)
// 	if err != nil {
// 		return fmt.Errorf("failed to upload blob: %w", err)
// 	}

// 	return nil
// }
