//These functions inside the asm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);

/**
* TODO: Show data on 7-seg via max7219_send
* Input:
* data: decimal value
* num_digs: number of digits will show on 7-seg
* Return:
* 0: success
* -1: illegal data range(out of 8 digits range)
*/
int display(int data, int num_digs)
{
	int i;
	for (i = 1; i <= num_digs; i++)
	{
		if(data >= 0){
			max7219_send(i , data % 10);
			data /= 10;
		}
		else max7219_send(i , 15);
	}
	for (i = num_digs ; i <= 8; i++)
		max7219_send(i, 15);
	return (data > 99999999) ? -1 : 0;
}

int main()
{
	int student_id = 616018;
	GPIO_init();
	max7219_init();
	display(student_id, 8);
}
