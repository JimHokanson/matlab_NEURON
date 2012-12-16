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
	public boolean detected_end_statement = false;   //Set true if we detect the 
	public boolean process_running        = false;
	public String  result_str             = new String();
	
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
		int n_bytes_available;
		int index_term_string_match; 
		String temp_string;
		boolean is_terminal_string = false;
		boolean is_terminal_string2 = false;
		long start_time = System.nanoTime();
		
		int next_input_index = 0;
		int next_err_index = 0;
		
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
				temp_string = new String(temp_data,0,n_bytes_available);
				index_term_string_match = temp_string.lastIndexOf(term_string_const);
				
				if (debug){
					System.out.println(temp_string);
				}
				System.arraycopy(temp_data,0,input_data,next_input_index,n_bytes_available);
				next_input_index = next_input_index + n_bytes_available;
				
				//END EARLY FOR NOW
				
				is_terminal_string2 = index_term_string_match != -1;
				System.out.printf("is terminal: %b\n", is_terminal_string2);
				
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
	
	public int checkIfTerminalString(String temp_string){

		return temp_string.lastIndexOf(term_string_const);

		
	}
}
