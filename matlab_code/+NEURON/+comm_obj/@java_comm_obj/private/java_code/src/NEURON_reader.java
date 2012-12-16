import java.io.*;  

//TO LOOK INTO:
//http://www.mathworks.com/support/solutions/en/data/1-9389FH/index.html?product=ML&solution=1-9389FH

public class NEURON_reader {
	
	BufferedInputStream pin;
	FileInputStream perr;
	Process p;
	
	String term_string_const;
	byte[] input_data = new byte[2000];
	byte[] error_data = new byte[2000];
	byte[] temp_data  = new byte[2000];

	//Set by class 
	public boolean good_read              = false;
	public boolean detected_end_statement = false;   //Set true if we detect the terminal string
	public boolean stackdump_present      = false;
	public boolean process_running        = false;
	public String  result_str             = new String();
	
	int next_input_index;
	int next_err_index;
	
	public NEURON_reader(BufferedInputStream pin, FileInputStream perr, Process p) {
		//Nothing currently needed ...
		this.p    = p;
		this.perr = perr;
		this.pin  = pin;
		term_string_const = String.format("\n<oc>\n");
	}
	
	public void read_result( long wait_time_seconds, boolean debug) throws IOException
	{

		long wait_time_nanoseconds = (long) (wait_time_seconds*1e9);
		long start_time = System.nanoTime();
		
		int n_bytes_available;
		int index_term_string_match; 
		
		next_input_index = 0;
		next_err_index = 0;
		
		boolean is_terminal_string = false;
		boolean is_terminal_string2 = false;
		
		String temp_string;
		

		//OUTLINE
		//------------------------------------------------------------------
		//1 Check if process is running
		//2 Check timing
		//3 Read input
		//4 Read error
		//5 Brief pause ????
		
		//Some initialization ...
		detected_end_statement = false;
		
		//Copying: System.arraycopy()
		
		while (true){
			//PROCESS RUNNING CODE
			//---------------------------------------------------
			//NOTE: Asking a process for its exit value will throw an error if it is still running
			//I don't know of any other way to ask if the process is still valid ...
			try {
				p.exitValue();
				process_running = false;
				break;
			} catch (IllegalThreadStateException e) {
				process_running = true;
			}
	
			//TIME CHECKING
			//---------------------------------------------------
			if (wait_time_nanoseconds != 0 && ((System.nanoTime() - start_time) > wait_time_nanoseconds)) {
				break;
			}
			
			is_terminal_string = true;
			
			//READING INPUT
			//---------------------------------------------------
			n_bytes_available = pin.available();
			if (n_bytes_available > 0){
				pin.read(temp_data,0,n_bytes_available);
				
				readStream(int n_bytes_available, boolean debug, boolean is_input_string)
				
				//Function after here ...
				temp_string = new String(temp_data,0,n_bytes_available);
				index_term_string_match = temp_string.lastIndexOf(term_string_const);
				
				if (debug){
					System.out.println(temp_string);
				}
				
				if (index_term_string_match != -1){
					if (index_term_string_match != 0){
						System.arraycopy(temp_data,0,input_data,next_input_index,n_bytes_available);
						next_input_index = next_input_index + n_bytes_available;
					}
					is_terminal_string = true;
					System.out.println("Terminal String Detected");
					break;
				}else{
					if (isStackdumpPresent(temp_string,true)){
						break;
					}
					System.arraycopy(temp_data,0,input_data,next_input_index,n_bytes_available);
					next_input_index = next_input_index + n_bytes_available;
				}
			}
			
			//READING ERROR
			//---------------------------------------------------
			n_bytes_available = perr.available();
			if (n_bytes_available > 0){
				perr.read(temp_data,0,n_bytes_available);
				
				//Make all of this a function 
				//Pass in which stream
				
				temp_string = new String(temp_data,0,n_bytes_available);
				index_term_string_match = temp_string.lastIndexOf(term_string_const);
				if (debug){
					System.err.println(temp_string);
				}
				System.arraycopy(temp_data,0,error_data,next_err_index,n_bytes_available);
				next_err_index = next_err_index + n_bytes_available;
				
				//END EARLY FOR NOW
				is_terminal_string = true; // checkIfTerminalString(n_bytes_available);
				is_terminal_string2 = index_term_string_match != -1;
				System.out.printf("is terminal: %b\n", is_terminal_string2);
				
			}
			
			//TODO: Check for stackdump - add prop, quit, throw error warning ...
			
			if (is_terminal_string){
				detected_end_statement = true;
				break;
			}
			
		}
		
		if (!detected_end_statement){
			good_read = false;
			return;
		}
		
		//SETTING THE FINAL STRING
		//--------------------------------------------------------------------------
		if (next_err_index > 0){
			good_read = false;
			//NOTE: We'll Ignore partially good strings for now ...
			/*
	        if obj.temp_stdout_index > 0
            obj.partial_good_str = obj.temp_stdout_str(1:obj.temp_stdout_index-1);
	        end
	        */
			result_str = new String(error_data,0,next_err_index);
		}else {
			good_read = true;
			//TODO: Extract good string
			result_str = new String(input_data,0,next_input_index);
		}
	}
	
	//isStackdumpPresent
	//==========================================================================
	private boolean isStackdumpPresent(String temp_string, boolean is_success){

		boolean potential_stackdump;
		String  possible_error_string;
		boolean stackdump_present = false;
		
		potential_stackdump = is_success && next_err_index > 0;
		if (potential_stackdump){
			possible_error_string = new String(error_data,0,next_err_index);
			stackdump_present     = possible_error_string.lastIndexOf("Dumping stack trace to") != -1;
			if (stackdump_present){
				System.err.printf("STACKDUMP ERROR MESSAGE:\n%s\n",possible_error_string);
			}
		}

		return stackdump_present;
	}
	
	private boolean readStream(int n_bytes_available, boolean debug, boolean is_input_string){
		
		String temp_string;
		int index_term_string_match; 
		
		//Bytes to string
		temp_string = new String(temp_data,0,n_bytes_available);
		
		//Check if the terminal string is present
		if (is_input_string){
			index_term_string_match = temp_string.lastIndexOf(term_string_const);
		}else{
			//NOTE: Error string will not have terminal string ...
			index_term_string_match = -1;
		}
		
		//Print out things if debugging ...
		if (debug){
			System.out.println(temp_string);
		}
		
		if (index_term_string_match != -1){
			//NOTE: This will ONLY occur for input strings ...
			//Trim string so that terminal string is not returned ...
			if (index_term_string_match != 0){
				System.arraycopy(temp_data,0,input_data,next_input_index,n_bytes_available);
				next_input_index = next_input_index + n_bytes_available;
			}
			System.out.println("Terminal String Detected");
			return true;
		}else{
			if (isStackdumpPresent(temp_string,is_input_string)){
				stackdump_present = true;
				return false;
			}
			if (is_input_string){
				System.arraycopy(temp_data,0,input_data,next_input_index,n_bytes_available);
				next_input_index = next_input_index + n_bytes_available;
			} else {
				System.arraycopy(temp_data,0,input_data,next_input_index,n_bytes_available);
				next_input_index = next_input_index + n_bytes_available;
			}
			return false;
		}
		
		
	}
	
}
