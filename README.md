### C-CAT-CALICO
Instructions for text transfer to CALICO (text_sender_for_mac.sh)  
Save the text you want to upload to CALICO with an appropriate filename (e.g., test.txt).  
Run the following commands in your Terminal:  
```
# Bash  
FILE="test.txt"  
xxd -p $FILE | tr '0-9' 'g-p' | split -b 2000 - p  
bash text_sender_for_mac.sh  
```
After pressing Enter, you have 3 seconds to move your mouse cursor to the Terminal inside the CALICO virtual desktop and click to focus it. 
The 16-bit encoded text will be automatically copied. 
Compare the file hashes between your Mac and CALICO to ensure they match.  
Note: The transmission repeats in 2000-byte chunks.  
Once the transfer is complete, decode the data using the following commands:  
```
# Bash
cat p?? > all_parts.txt
cat all_parts.txt | tr 'g-p' '0-9' | xxd -r -p > test.txt
```
After transfer, remove temporary files.  
