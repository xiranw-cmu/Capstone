/* main.cpp - Client for the Tx/Rx Program
 * Author: Michael A. Galle
 *
 */

#include <Windows.h>    
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "RS232Comm.h"

// Note: Comment out the Tx or Rx sections below to operate in single sided mode

// Declare constants, variables and communication parameters
const int BUFSIZE = 140;							// Buffer size
wchar_t COMPORT_Rx[] = L"COM7";						// COM port used for Rx (use L"COM6" for transmit program)
wchar_t COMPORT_Tx[] = L"COM7";						// COM port used for Rx (use L"COM6" for transmit program)

// Communication variables and parameters
HANDLE hComRx;										// Pointer to the selected COM port (Receiver)
HANDLE hComTx;										// Pointer to the selected COM port (Transmitter)
int nComRate = 512000;					// Baud (Bit) rate in bits/second 
int nComBits = 8;									// Number of bits per frame
COMMTIMEOUTS timeout;								// A commtimeout struct variable

 // The client - A testing main that calls the functions below
int main() {

	// Set up both sides of the comm link
	initPort(&hComRx, COMPORT_Rx, nComRate, nComBits, timeout);	// Initialize the Rx port
	Sleep(500);
	//initPort(&hComTx, COMPORT_Tx, nComRate, nComBits, timeout);	// Initialize the Tx port
	//Sleep(500);

	// Transmit side 
	char msgOut[] = "CaGtDRogE";		// Sent message	0x48 (0100_1000), 0x65 (0110_0101)
	outputToPort(&hComRx, msgOut, strlen(msgOut));			// Send string to port - include space for '\0' termination
	Sleep(50);													// Allow time for signal propagation on cable 

	// Receive side  
	char msgIn[BUFSIZE];
	DWORD bytesRead;
	bytesRead = inputFromPort(&hComRx, msgIn, BUFSIZE);			// Receive string from port
	printf("Length of received msg = %d", bytesRead);
	msgIn[bytesRead] = '\0';
	printf("\nMessage Received: %x %x %x %s\n", msgIn[0], msgIn[1], msgIn[2], msgIn);				// Display message from port
	
	// Tear down both sides of the comm link
	purgePort(&hComRx);											// Purge the Rx port
	//purgePort(&hComRx);											// Purge the Tx port
	CloseHandle(hComRx);										// Close the handle to Rx port 
	//CloseHandle(hComRx);										// Close the handle to Tx port 
	
	system("pause");
}