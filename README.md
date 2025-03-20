# Book a Shipment - Flutter App
[![Watch the video](https://img.icons8.com/clouds/100/000000/video-playlist.png)](https://drive.google.com/file/d/1-3UpXmfyLbD4NLEqur8Z5B2f6bEWgM-R/view?usp=sharing)


A Flutter-based mobile application for booking shipments with ease. Users can select pickup and delivery cities, choose a courier, view the price, and proceed to payment with a modern "Slide to Payment" action. The app integrates with a mock API to fetch shipping rates and provides a seamless user experience with animations and a clean UI.

## Features

- **Select Pickup and Delivery Cities**: Choose from a list of predefined cities (e.g., Delhi, Mumbai, Bangalore) using a hybrid dropdown/autocomplete field.
- **Choose a Courier**: Select a courier service (e.g., Delhivery, DTDC, Bluedart) from a dropdown menu.
- **View Price**: Automatically calculates and displays the shipping price based on the selected cities and courier.
- **Slide to Payment**: A modern "Slide to Payment" action to confirm the booking, ensuring an intuitive user experience.
- **Confirmation Screen**: Displays booking details with a positive quote after successful payment.
- **Animations**: Includes fade and slide animations for a smooth UI experience.
- **Responsive Design**: Works seamlessly on different screen sizes with a light purple gradient background.

## App Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/bhaktii98/book-a-shipment-flutter/main/3.jpg" width="250">
  <img src="https://raw.githubusercontent.com/bhaktii98/book-a-shipment-flutter/main/2.jpg" width="250">
  <img src="https://raw.githubusercontent.com/bhaktii98/book-a-shipment-flutter/main/1.jpg" width="250">
</p>

## How the App Works

1. **Launch the App**: The app opens to the "Book Your Shipment" screen with a light purple gradient background.
2. **Select Pickup and Delivery Cities**:
   - Use the hybrid dropdown/autocomplete fields to select the pickup and delivery cities.
   - The fields support both manual typing (with autocomplete suggestions) and dropdown selection.
3. **Choose a Courier**:
   - Select a courier from the dropdown menu (e.g., Delhivery, DTDC, Bluedart).
4. **View Price**:
   - The app fetches the shipping price from the API based on the selected cities and courier.
   - The price is displayed as "Price: ₹[amount]" (e.g., "Price: ₹180").
5. **Slide to Payment**:
   - Slide the "Slide to Payment" button to confirm the booking.
   - If all fields are selected, the app navigates to the confirmation screen.
   - If any field is missing, a snackbar displays "Please select all fields".
6. **Confirmation Screen**:
   - Displays the booking details (pickup, delivery, courier, price).
   - Shows a random positive quote (e.g., "Happiness is on its way – your shipment has been placed!").
   - Includes a "Back to Home" button to return to the main screen.

## API Integration

### API Used
The app integrates with a mock API to fetch shipping rates based on the selected pickup city, delivery city, and courier. The API endpoint used is:

- **Endpoint**: `https://67db028c1fd9e43fe4733fb8.mockapi.io/api/v1/shipping_rates`
- **Method**: GET
- **Response Format**: JSON

Example response:
```json
[
  {
    "pickup": "Mumbai",
    "delivery": "Delhi",
    "courier": "DTDC",
    "price": 180
  },
  {
    "pickup": "Mumbai",
    "delivery": "Delhi",
    "courier": "Bluedart",
    "price": 220
  }
]
