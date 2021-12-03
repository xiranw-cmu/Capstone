/* main.cpp - Client for the Tx/Rx Program
 * Author: Michael A. Galle
 *
 */

#include <Windows.h>    
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "RS232Comm.h"

#include <chrono>
using namespace std::chrono;

// Note: Comment out the Tx or Rx sections below to operate in single sided mode

// Declare constants, variables and communication parameters
const int BUFSIZE = 4096;							// Buffer size
wchar_t COMPORT_Rx[] = L"COM7";						// COM port used for Rx (use L"COM6" for transmit program)
wchar_t COMPORT_Tx[] = L"COM7";						// COM port used for Rx (use L"COM6" for transmit program)

// Communication variables and parameters
HANDLE hComRx;										// Pointer to the selected COM port (Receiver)
HANDLE hComTx;										// Pointer to the selected COM port (Transmitter)
int nComRate = 576000;					// Baud (Bit) rate in bits/second 
int nComBits = 8;									// Number of bits per frame
COMMTIMEOUTS timeout;								// A commtimeout struct variable

 // The client - A testing main that calls the functions below
int main() {

	// Set up both sides of the comm link
	initPort(&hComRx, COMPORT_Rx, nComRate, nComBits, timeout);	// Initialize the Rx port
	//Sleep(500);
	//initPort(&hComTx, COMPORT_Tx, nComRate, nComBits, timeout);	// Initialize the Tx port
	//Sleep(500);

	// Transmit side 
	char msgOut1[] = "Ab Cd Ef gH Ab Cd Ef gH Ab Cd Ef gH ";		// Sent message	0x48 (0100_1000), 0x65 (0110_0101)
	char msgOut2[] = "Hi Pe Op Le Ho WA Ar EY ou ";
																																																																			//char msgOut[] = "Hi Ei OO ";
	auto start = high_resolution_clock::now();
	int count = 0;
	// initialize file I/O

	// figure out how many lines
	for (int i = 0; i < 200; i++) {
		count++;
		// auto init = high_resolution_clock::now();
		// if (i % 2 == 0)
		// 	outputToPort(&hComRx, msgOut1, strlen(msgOut1));			// Send string to port - include space for '\0' termination
		// else
		// 	outputToPort(&hComRx, msgOut2, strlen(msgOut2));
		char msg [] = readline();
		// convert hex -> ascii & add 1 extra character
		outputToPort(&hComRx, msg, strlen(msg));
		
		// auto middle = high_resolution_clock::now();
		// auto dur = duration_cast<microseconds>(middle - init);
		//printf("time to output: %d\n", dur);
		//Sleep(500);													// Allow time for signal propagation on cable 

		// Receive side  
		char msgIn[BUFSIZE];
		DWORD bytesRead;
		// init = high_resolution_clock::now();
		bytesRead = inputFromPort(&hComRx, msgIn, BUFSIZE);			// Receive string from port
		// string is in msgIn
		// convert ascii to hex, and then discard the last hex character
		// shove into text file
		// auto end = high_resolution_clock::now();
		// dur = duration_cast<microseconds>(end - init);
		//printf("time to input: %d count: %d\n", dur, count);
																	//printf("Length of received msg = %d", bytesRead);
		//msgIn[bytesRead] = '\0';
		//printf("Message Received: %x %x %x %s\n", msgIn[0], msgIn[1], msgIn[2], msgIn);				// Display message from port
	}

	char msgIn[BUFSIZE];
	DWORD bytesRead;
	auto init = high_resolution_clock::now();

	//bytesRead = inputFromPort(&hComRx, msgIn, BUFSIZE);			// Receive string from port
	//msgIn[bytesRead] = '\0';
	auto end = high_resolution_clock::now();
	auto dur = duration_cast<microseconds>(end - init);
	//printf("%s\n", msgIn);
	printf("COUNT: %d\n", count);
	printf("time to input: %d\n", dur);
	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<microseconds>(stop - start);
	printf("duration (us): %d\n", duration);

	// Tear down both sides of the comm link
	purgePort(&hComRx);											// Purge the Rx port
	//purgePort(&hComRx);											// Purge the Tx port
	CloseHandle(hComRx);										// Close the handle to Rx port 
	//CloseHandle(hComRx);										// Close the handle to Tx port 
	
	system("pause");
}