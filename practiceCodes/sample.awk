BEGIN{
	count = 0;
	array[10];
}

{
	

	

	array[count++] = $1+" "+$2+" "+$3+" "+$6;


}

END{
	
	for(i=0;i<count;i++)
	{
		print(array[i]);
	}
}