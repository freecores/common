#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "veriuser.h"
#include "acc_user.h"

#define TRUE 1 
#define FALSE 0 
#define MAX_BUFFER_SZ	2048
#define MAX_NAME_SZ		128
#define OUT_FILE_EXT 	".ver"
#define COLON			':'
#define OFFSET		  	9
#define H10		  		0x10L
#define AWORD			8
#define WORDS_PER_LINE	8
#define MASK15 			0x000000FFL
#define EXT_STR 		".ver"

typedef enum {
	OK 		= 0,
	WARNING = 1,
	ERROR 	= 2
}STATUS;
static int line_no = 0;
/********************************************************************
 * char* trimAlteraExt(char* oldName, char* newName)
 * oldName : original file name.
 * newName : new file name which doesnt have file extension.
 *
 * This function trims the file extension
 * Looks for first "." and trims the file name afterwords.
********************************************************************/

char* trimAlteraExt(oldName, newName)
char* oldName;
char* newName;
{
    char tempStr[MAX_BUFFER_SZ];
    char* tempPtr=NULL;

    newName[0]='\0';
    if(oldName[0]=='\0')
        return NULL;
    strcpy(tempStr, oldName);
    if(tempPtr = strstr(tempStr, "."))
    {
        *tempPtr = '\0';
    }
    strcpy(newName, tempStr);
    return newName;
}

/****************************************************************/
int display_msg(status, str, data_file)
STATUS status;
char *str;
char *data_file;
{
	switch(status)
	{
		case WARNING:
			 printf("WARNING: %s, %s\n\n", data_file, str);
			break;
		case ERROR:
			 printf("ERROR:%s, line %d, %s\n\n", data_file, line_no, str);
			break;
		default:
			break;
	}
	return(TRUE);
}
/****************************************************************
  char *ltrim(str)                                                     
  char *str;                                                           
  Deletes leading blanks in string 'str'                             
****************************************************************/               
char *ltrim(str)
char *str;
{  
   	int i = 0,j = 0;

	/* Illeagal application. Returns NULL. */
   	if (str == 0) return(0);  
   	/* Deletes leading blanks */
   	while (*(str + i) == ' ' || *(str + i) == '\n' || *(str + i) == '\t' || *(str + i) == '\b') i++;
   	for (; *(str + i) != '\0'; i++,j++) *(str + j) = *(str + i); 
	/* Appends a NULL character to the end of the string */
   	*(str + j) = '\0';  
   	
	return(str);
}

/****************************************************************
 * Function: write_ver_data
 * Description: This function ensures that each char (in hex)
 * 		represents a nibble of the data.
 * For example if (width<5) we need to output only 1 char hex. 
****************************************************************/      
void write_ver_data(ofp, width, data)
FILE *ofp;
int width;
char *data;
{
  int num_nibbles;
  int num_hex;

  num_nibbles = (width%4?(width/4 + 1):width/4);
  num_hex = num_nibbles/2;

  while (num_hex--)
  {
    fprintf(ofp, "%c%c", data[0], data[1]);
    data +=2;
  }
  /* NB: we skip the leading '0' in data[0]. */
  if (num_nibbles&1) fprintf(ofp, "%c", data[1]);
}
  
/****************************************************************
Function: write_data
Description: Write ROM data in the verilog format so that
	it can be read using readmemh(infile, rom)
Format:	example data format for the 8 bit data
		@1
		01 02 03 04 05 06 07 08
		@a
		0a 0b 0c      
****************************************************************/      
int write_data(ofp, nn, aaaa, off_addr, dddd, width)
FILE *ofp;
long nn, aaaa, off_addr;
char *dddd;
int width;
{
	int count, i;
    char data[MAX_BUFFER_SZ +1];
	int num_hexs, nibbles ;


	if((width % AWORD) == 0)
	{
		num_hexs = width/AWORD;
	}
	else
	{
		num_hexs = (width/AWORD) + 1;
	}
	
	fprintf(ofp, "@%x\n", aaaa + off_addr);
	
	nibbles  = num_hexs*2;
	count = 1;
	while(nn > 0)
	{
		if(nn >= num_hexs)
		{
			strncpy(data, dddd, nibbles);
			data[nibbles] = '\0';
		}
		else
		{
			for(i = 0; i < (num_hexs - nn); i++)
			{
				sprintf(data + i*2, "%s", "00");
			}
			strcat(data + (num_hexs - nn), dddd);
		}	
		write_ver_data(ofp, width, data);
		if(count < WORDS_PER_LINE)
		{
			count ++;
		}
		else
		{
			fprintf(ofp, "\n");
			count = 1;
		}
		dddd = dddd + nibbles;
		nn -= num_hexs;
	}
	if(count > 1)
		fprintf(ofp, "\n");

		
}
/****************************************************************/
/* Convert Intel-hex format data to verilog format data 		*/
/* 	Intel-hex format 	:nnaaaaattddddcc 						*/
/****************************************************************/
convert_hex2ver()
{
    char buffer[MAX_BUFFER_SZ +1]; 
	char out_file[MAX_NAME_SZ +1];
	char init_filename[MAX_NAME_SZ +1];
    char dddd[MAX_BUFFER_SZ +1];
	char *in_file, *out_str;

	FILE *ifp, *ofp;
	int i ;
	int done = FALSE;
	int first_rec = FALSE;
	int last_rec = FALSE;
	int width ;
	long off_addr, nn, aaaa, tt, cc, aah, aal, dd, sum ;
	handle wrk;
	static s_setval_value user_s = {accStringVal};
	static s_setval_delay delay ;
			
	off_addr= nn= aaaa= tt= cc= aah= aal= dd= sum = 0;

	in_file = (char *)tf_getcstringp(1);
	width = tf_getp(2);
	trimAlteraExt(in_file, out_file);
	strcat(out_file, OUT_FILE_EXT);
    if ((ifp = fopen(in_file, "r")) == NULL)
    {
       	printf("cannot read %s\n", in_file);
       	fclose(ifp);
		return;
    }
    if ((ofp = fopen(out_file, "w")) == NULL)
    {
       	printf("cannot write %s\n", out_file);
       	fclose(ofp);
		return;
    }
	while(!done)
	{
      	if(fgets(buffer, MAX_BUFFER_SZ, ifp) == NULL)
		{
			if(!first_rec)
				done = display_msg(WARNING, "Intel-hex data file is empty.", in_file);
			else if(!last_rec)
				done = display_msg(ERROR, "Missing the last record.", in_file);
		}
		else if(strlen(ltrim(buffer)) == 0)
		{
			line_no++;
		}
		else if(buffer && (buffer[0] == COLON))
		{
			line_no++;
			first_rec = TRUE;
		   	sscanf(buffer+1,"%02x%04x%02x", &nn, &aaaa, &tt);
			if((tt == 2) && (nn != 2) )
			{
				done = display_msg(ERROR, "Invalid data record.", in_file);
			}
			else
			{
		   	sscanf(buffer+3,"%02x%02x", &aah, &aal);
			sum = nn + aah + aal + tt ;
			for(i = 0; i < nn; i++)
			{
				sscanf(buffer+OFFSET+i*2, "%02x", &dd);
				sprintf(dddd+i*2, "%02x", dd);
				sum += dd;
			}
   			sscanf(buffer+OFFSET+i*2, "%02x\n", &cc);

   			switch(tt) {
   				case 0x00: /* normal_record */
					first_rec = TRUE;
					if(((~sum + 1)& MASK15) == cc)
					{
						write_data(ofp, nn, aaaa, off_addr, dddd,width);
						off_addr = 0;
					}
					else
					{
						done = display_msg(ERROR, "Invalid checksum.", in_file);
					}
   				break;
   				case 0x01: /* last record */
					last_rec = TRUE;
					if(((~sum+1)&MASK15) != cc)
					{
						display_msg(ERROR, "Invalid checksum.", in_file);
					}
					done = TRUE;
   				break;
   				case 0x02: /* address base record */
		   			sscanf(dddd,"%x\n", &off_addr);
					if(((~sum +1)& MASK15) == cc)
					{
						off_addr *=  H10;
					}
   					else
					{
						done = display_msg(ERROR, "Invalid checksum.", in_file);
					}
   				break;
   				default:
   					done = display_msg(ERROR, "Unknown record type.", in_file);
   				break;
		    } /* switch */
			}
		}
		else
		{
			line_no++;
			display_msg(ERROR, "Invalid INTEL HEX record", in_file);
			done = TRUE;
		}
  	}
  	fclose(ifp);
  	fclose(ofp);
	/* append EXT_STR to the input string and pass it back in arg 1 */
	delay.model = accNoDelay;
	wrk = acc_handle_tfarg(3);
	trimAlteraExt(in_file, init_filename);
	strcat(init_filename, EXT_STR);
	user_s.value.str = init_filename;
	acc_set_value(wrk, &user_s, &delay);
	
	return(0);
}

