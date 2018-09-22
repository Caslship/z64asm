#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <stdlib.h>

using namespace std;

int main()
{
	// Variables used for files
	string FilePath;
	ifstream In;
	ofstream Out;

	// Address to write to
	unsigned int GS_Write;

	// Variables used for nemu cheat files
	char NemuFormat;
	string CheatName;
	unsigned int CheatNumber;

	// Variables used for temporary reading
	unsigned int TEMP;
	string TEMP_s;
	int i = 0;
	int j = 0;

	// Get filepath to text file that holds gameshark code
	cout << "Gameshark file: ";
	getline(cin, FilePath);

	// Get the address to write to
	cout << "Address to write values to: ";
	cin >> hex >> GS_Write;
	if (GS_Write >= 0x80800000) return -1;

	// Format the address for gameshark code writing
	GS_Write = ((GS_Write & 0x00FFFFFF) | 0x81000000);

	// Get whether or not to output as a nemu cheat
	cout << "Format the output as a nemu cheat? (y / n): ";
	cin >> NemuFormat;	
	if (NemuFormat == 'y' || NemuFormat == 'Y')
	{
		// Get cheat name
		cin.ignore();
		cout << "Cheat name: ";
		getline(cin, CheatName);

		// Get cheat number
		cout << "Cheat number: ";
		cin >> dec >> CheatNumber;
		if (CheatNumber < 0) return -1;
	}

	// Open files
	In.open(FilePath.data());
	if (!In || !In.is_open() || !In.good() || In.fail()) return -1;
	Out.open("out.txt");
	if (!Out || !Out.is_open() || !Out.good() || Out.fail()) return -1;

	// Grab values from text file that holds gameshark code
	Out << hex << uppercase;
	In >> hex;
	while (In >> TEMP)
	{
		// If we are currently on the address of a gameshark code...
		if (!(i % 2))
		{
			unsigned int hi_addr = TEMP >> 16;
			unsigned int lo_addr = TEMP & 0x0000FFFF;
			Out << GS_Write + j << " " << setfill('0') << setw(4) << hi_addr << endl;
			Out << GS_Write + 0x02 + j << " " << setfill('0') << setw(4) << lo_addr << endl;
		}
		// Else we are on the value to write to that address... 
		else
		{
			Out << GS_Write + 0x04 + j << " " << setfill('0') << setw(4) << TEMP << endl;
			j += 0x06;
		}

		i++;
	}

	// Output number of lines of gameshark code
	cout << "Processed " << (i / 2) << " lines.\n";

	// Close files
	In.close();
	Out.close();

	// If we wanted to have a nemu formatted cheat code...
	if (NemuFormat == 'y' || NemuFormat == 'Y')
	{
		// Open files
		In.open("out.txt");
		if (!In || !In.is_open() || !In.good() || In.fail()) return -1;
		Out.open("nemu.txt");
		if (!Out || !Out.is_open() || !Out.good() || Out.fail()) return -1;

		// Specify cheat name
		Out << dec;
		Out << "CheatName" << CheatNumber << "=" << CheatName << endl;

		// Grab values from text file that holds gameshark code 
		i = 0;
		while (In >> TEMP_s)
		{
			// If we are currently on the address of a gameshark code, specify code line and start the code
			if (!(i % 2)) Out << "CheatName" << CheatNumber << "Code" << (i / 2) << "=" << TEMP_s << " ";
			// Else we are on the value to write to that address, write the code value 
			else Out << TEMP_s << endl;

			i++;
		}
		// Specify the number of lines of gameshark code in cheat
		Out << "CheatName" << CheatNumber << "Count=" << (i / 2) << endl;
		
		// Close files
		Out.close();
		In.close();

		// Delete the old "out.txt" file
		#if defined(WIN32) || defined(WIN64)
		system("del out.txt");
		#elif defined(UNIX)
		system("rm out.txt");
		#endif
	}

	// Exit
	cin.get();
	cin.ignore();
	return 0;
}

	


	