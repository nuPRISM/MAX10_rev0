
import java.io.File;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.util.Calendar;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.altera.systemconsole.core.IAddress;
import com.altera.systemconsole.core.ISystemConsole;
import com.altera.systemconsole.core.ISystemFilesystem;
import com.altera.systemconsole.core.ISystemNode;
import com.altera.systemconsole.core.SystemConsoleProvider;
import com.altera.systemconsole.core.ISystemFilesystem.WellKnownLocation;
import com.altera.systemconsole.core.services.ILoaderService;
import com.altera.systemconsole.core.services.IMemoryService;
import com.altera.systemconsole.core.services.IProcessorService;
import com.altera.systemconsole.elf.ELFProvider;
import com.altera.systemconsole.elf.IELF;
import com.altera.systemconsole.elf.ISection;
import com.altera.systemconsole.elf.ISegment;
import com.altera.systemconsole.elf.IProgramHdr.SegmentType;
import com.altera.systemconsole.elf.ISectionHdr.SectionType;
import com.altera.systemconsole.Avalon_Fast_Downloader.AvalonFastDownloaderMemoryService;
import com.altera.systemconsole.internal.elf.ELFLoader;
import com.altera.systemconsole.jtag.INodeInfo;

/**
 * 
 * Feb 18 009 -- CJR Changed the endaddress on the messages to reflect the offset.  
 * March 6 009 -- CJR Added processor instance 
 */

public class DownloadElf {
	public static void main(String[] args) {
		boolean mode_go = false;
		boolean mode_debug = false;
		boolean mode_verify = false;
		boolean mode_download = true;
		boolean mode_crc = false;
		boolean mode_hex = false;
		boolean mode_header = false;
		int offset =0;
		int length =0x10000;
		int address = 0x024c040c;
		int g_instance = 0;
		System.out.println("Fast_downloader utility V1.0b March 6, 2009\n");
		//System.out.println("Path :"+System.getenv("PATH"));
		System.out.printf("Options selected -> ");
		for(int i=0;i<args.length;i++)
		{
			System.out.printf("%s ",args[i]);
		}
		System.out.printf("\n");
		if (args.length < 1) {
			System.err.println("No file specified...");
			System.exit(1);
		}
		File f = new File(args[0]);
		if (! f.exists()) {
			System.err.println("File doesn't exist: "+f);
			System.exit(1);
		}  
		for(int i=1;i<args.length;i++)
		{
			if(args[i].equalsIgnoreCase("-g"))
				mode_go =true;
			if(args[i].equalsIgnoreCase("-d"))
				mode_debug =true;
			if(args[i].equalsIgnoreCase("-v"))
				mode_verify =true;
			if(args[i].equalsIgnoreCase("-vo"))
				{
				mode_download =false;
				mode_verify =true;}
			if(args[i].equalsIgnoreCase("-c"))
				mode_crc =true;
			if(args[i].equalsIgnoreCase("-p"))
				mode_header =true;
			if(args[i].equalsIgnoreCase("-o"))
				{
				offset = Integer.parseInt(args[++i], 16);
				}
			if(args[i].equalsIgnoreCase("-ip"))
			{
			    g_instance  = Integer.parseInt(args[++i], 16);
			}
			if(args[i].equalsIgnoreCase("-hex"))
				{
					
					mode_hex =true;
					address = Integer.parseInt(args[++i], 16);       // read a hex number
					length = Integer.parseInt(args[++i], 16);       // read a hex number
					
				}
			if(args[i].equalsIgnoreCase("-h"))
				{
				System.out.println("fast_downloader file <-g> <-d> <-v> <-c> <-h>\n");
				System.out.println("  <-g> start processor running if not set the processor remains in pause");
				System.out.println("  <-d> print extra debug messages -- not implimented");
				System.out.println("  <-v> verify what was written");
				System.out.println("  <-vo> verify only no write");
				System.out.println("  <-o offset> offset is in hex with no leading 0x");
				System.out.println("  <-p > prepend a 32 bit address and length");		
				System.out.println("  <-hex address length> address & length are in hex with no leading 0x output c:\\output.hex");		
				System.out.println("  <-c> preform crc check  -- not imlimented yet");
				System.out.println("  <-ip nu> instnace number of the processor");
				System.out.println("  <-h> this message");
				System.exit(1);
				}	
		}
		if(mode_header)	// make room for the header.
			offset = offset + 8;
		try {
			// Find a system console implementation
			final ISystemConsole sysc = SystemConsoleProvider.createDefault();  
			Logger l =Logger.getLogger(ISystemConsole.LOG_NAME);
			//l.setLevel(Level.OFF);  //turn off all the extra java message. 
			l.setLevel(Level.ALL);  //turn on all messages. 
			if(mode_debug==true)
				l.setLevel(Level.FINE);
			// This must be called before doing anything as it starts up the event handling thread.			
			sysc.start(true);                                    
			// Arrange to automatically clean up
			Runtime.getRuntime().addShutdownHook(new Thread() {
				@Override
				public void run() {
					sysc.stop();
					System.out.println("System Console cleanly shutdown");
				}
			});
			
			
			ISystemFilesystem fs = sysc.getVirtualFilesystem();
			ISystemNode connections = fs.getConnectionPoint(WellKnownLocation.connections);

// now look to see if a nios exists and put it into reset.	
			Collection<ISystemNode> pNodes = fs.findDescendantsByType(connections, IProcessorService.class);
			ISystemNode foundPNode = null;
			for (ISystemNode nodeInQuestion : pNodes) {
				 System.out.printf(" found node %s\n",nodeInQuestion.getName());
			    // check that this node is the one I want
				INodeInfo ni = nodeInQuestion.getInterface(INodeInfo.class);
			    if (ni.getInstanceID() == g_instance ) {   // or some other check – instance ID, etc
			       foundPNode = nodeInQuestion;
			       System.out.printf(" found NiosII %s",foundPNode.getName());
			       break;
			    }
			 }
			    // now open and put into debug.
			 if(foundPNode !=null){
               IProcessorService processor = foundPNode.getInterface(IProcessorService.class);
               processor.open();
               // don't want the nios running while I am downloading code
               processor.resetAndEnterDebugMode();
               processor.close();
				 System.out.printf("A Nios was found and reset\n");

			 }
			 else{
				 // nothing really to do only need to do something if a nios exists.
				 System.out.printf("****** No Nios was found to reset**********\n");
			 }
			 // no for upening up the fast downloader
			Collection<ISystemNode> nodes = fs.findDescendantsByType(connections, IMemoryService.class);
			ISystemNode myNode = null;
			if (! nodes.isEmpty()) {
				// now find the specific interface
				for (ISystemNode n : nodes){
					INodeInfo ni = n.getInterface(INodeInfo.class);
					System.out.printf(" found IMemoryService %s.\n",n.getName());
//					if((ni.getNodeID()==FastTransactoMemoryService.AvalonFastDownloaderRegion.FAST_JTAG_ID)||(ni.getNodeID()==134)){ // this is the node number we are looking for
					if((ni.getNodeID()==AvalonFastDownloaderMemoryService.AvalonFastDownloaderRegion.FAST_JTAG_ID)){ // this is the node number we are looking for
						 // found it.
                        myNode = n;
                        System.out.printf(" Found fast downloader here.\n");
                        IMemoryService memory = myNode.getInterface(IMemoryService.class);
                      
                        memory.open();
                        // modify the parameters on the fast interface 
                //        AvalonFastDownloaderMemoryService fast_interface = AvalonFastDownloaderMemoryService(AvalonFastDownloaderMemoryService.class);
                        AvalonFastDownloaderMemoryService fast_interface = (AvalonFastDownloaderMemoryService)memory;
                         fast_interface.set_params(mode_verify, mode_download, offset, true);
                        
                     
                       
                        
                        // star the loader
                        ELFLoader loader = new ELFLoader();
                        Calendar startcal = Calendar.getInstance();
                        System.out.println(startcal.getTime());
                     // Get current time
                       
                        long start = System.currentTimeMillis();
                        ILoaderService.ILoadProgressNotifier progress = new com.altera.systemconsole.core.services.ILoaderService.ILoadProgressNotifier() {
                        	@Override
                        	public void loadProgress(String section, int sectionLoaded,
							int sectionTotal, int programLoaded,
							int programTotal) {
                        	System.out.printf("%f loaded of %dKBytes\n", programLoaded * 100.0f / programTotal, programTotal/1024);
                        	}
                        };
                        if(mode_header)
                        {
                        	IAddress iaddress = null ;
                        	int total;
                        	IELF elf = ELFProvider.open(f);
                    		List<ISection> sections = new LinkedList<ISection>();
                    		List<ISegment> segments= elf.getSegments();		// this is needed to accesp the logical address the 
                    		total = getSectionsToLoad(elf, sections);
                    //		int curr = 0;
                    //		ISection s = sections;
                    		for (ISection s : sections) {
                    			iaddress = s.getSectionVirtualAddress(); // to keep the compiler happy
                    			int loffset = (int) s.getSectionFileOffset();
                    			long laddr =  s.getSectionVirtualAddress().getLowerValue();
                    			for(ISegment seg:segments)// cal was here  
                    			{							// need to match the section up with the segments becuase the segmenst have the logical or phsyical address.
                    										// it seems silly to have to do this but it works. 
                    										// I didn't see another way to do it. 
                    				int ioffset = seg.getOffset();
                    				long addr = seg.getVirtualAddress().getLowerValue(); // this might be it
                    				if ((loffset == ioffset) && (laddr == addr)) {
                    					iaddress =seg.getPhysicalAddress();
                    				}
                    			}
                    		//	curr += loadSection(ps, s, curr, total, progress, address);
                    			break;
                    		}

                    		
                        	
                        	
                        	byte[] theAddress = null;
                        	byte[] theSize = null;
                        	theAddress = longToByteArray(iaddress.getLowerValue());
                        	ByteBuffer buff = ByteBuffer.allocate(4);
                        	buff.put(theAddress, 0, 4);
           // cal work           	buff.put(theSize, 0, 4); // i would thin I could do this but I will test it later
                         	IAddress oiaddress = memory.createRelativeAddressInBytes(iaddress, -8 ); //move the address back by 8
                        	memory.write(oiaddress, buff); 
                        	
                        	theSize = longToByteArray(total);
                        	ByteBuffer buff1 = ByteBuffer.allocate(4);
                        	buff1.put(theSize, 0, 4);
                           	oiaddress = memory.createRelativeAddressInBytes(iaddress, -4 ); //move the address back by 4
                         	memory.write(oiaddress, buff1); // offset will automatically be added in                     
                        	 

                        }
                        if(mode_hex )
                        {
  //working here
                        	//int j = 32;  // number of chars per line
                        	byte[] bytes;
                        	
                        	ByteBuffer buff = ByteBuffer.allocate(length);              	
                       // 	fast_interface.transmitBuffer(AvalonFastDownloaderMemoryService.AvalonFastDownloaderRegion.READ_MODE, address, buff);
                         	memory.read( memory.createAddress(address), buff);
                        	FileOutputStream fout = new FileOutputStream("C:/test.hex");
                        	int m = buff.remaining();
                        	if (buff.hasArray()){
                    			bytes = buff.array();
                    		}
                    		else
                    		{	
                    			bytes = new byte[m];
                    			buff.get(bytes, 0, buff.remaining());
                    		}
                        //	for(int i =0;i<length;i++)
                        	{
                        		
                        			fout.write(byteArrayToHexString(bytes));
                        	}
                        	fout.close();
                        	System.out.printf("C:/test.hex file complete");
                        }
                        else
                        {
                           loader.load(memory, f, myNode, progress);
                        }
                        memory.close();
                        long elapsedTimeMillis = System.currentTimeMillis()-start;
                        System.out.printf("elapsed time %ds\n", elapsedTimeMillis/1000);
                        Calendar endcal = Calendar.getInstance();
                        System.out.println(endcal.getTime());  
                        
                        // now reopen the processor interface to load the start address and set it going
           			 if(foundPNode !=null){
                         IProcessorService processor = foundPNode.getInterface(IProcessorService.class);           
//                        if (! pNodes.isEmpty()){
//				        	ISystemNode processorNode = pNodes.iterator().next();
//				        	IProcessorService processor = processorNode.getInterface(IProcessorService.class);
				        	processor.open();
				        	// even though it should already be in debug mode 
				        	processor.enterDebugMode();
				        	// here is where the real work gets done.
				        	if(mode_hex == false)
				        		loader.initializeRegisters(processor, myNode);
				        	//end debug I think this will set it running
				        	if(mode_go){
				        		processor.leaveDebugMode();
				        		System.out.printf("Nios running\n");
				        	}
				        	else
				        	{
				        		System.out.printf("Leaving the Nios Paused\n");
				        	}
				        	processor.close();
				        	//all done. 
				        }
           			 // don't need to try and do anything else so break;
           			 break;
					}
				}
//				else
//				{
//					System.out.printf("No fast downloader found\n");
//				}
				
				 
			} else {
                             System.out.println("ERROR: no memory masters found in system");
                             sysc.stop();
			     System.exit(1);
			}
                        sysc.stop();
			System.exit(0);
		} catch (Throwable t) {
			t.printStackTrace();
			System.exit(1);
		}
	}
	/**
	* Convert a byte[] array to readable string format. This makes the "hex"
	readable!
	* @return result String buffer in String format 
	* @param in byte[] buffer to convert to string format
	*/
	public static byte[] byteArrayToHexString(byte in[]) {
	    byte ch = 0x00;
	    int i = 0; 
	    if (in == null || in.length <= 0)
	        return null;
	        
	    byte pseudo[] = {'0', '1', '2',
	'3', '4', '5', '6', '7', '8',
	'9', 'A', 'B', 'C', 'D', 'E',
	'F'};
	    byte [] out = new byte[in.length * 2 + in.length/16];
	    int k=0;
	    while (i < in.length) {
	        ch = (byte) (in[i] & 0xF0); // Strip off high nibble
	        ch = (byte) (ch >>> 4);
	     // shift the bits down
	        ch = (byte) (ch & 0x0F);    
	// must do this is high order bit is on!
	        out[k++]= (pseudo[ (int) ch]); // convert the nibble to a String Character
	        ch = (byte) (in[i] & 0x0F); // Strip off low nibble 
	        out[k++] = (pseudo[ (int) ch]); // convert the nibble to a String Character
	        i++;
	        if((i % 32)==0)
	        	out[k++] = '\n';
	    }
	    return out;
	}  
	public static void printNode (ISystemNode n, String indent) {
		System.out.println(indent+n.getName());
		for (ISystemNode child : n.getChildren() ) {
			printNode(child, indent+"  ");
		}
	
	}
	public static final byte[] longToByteArray(long value) {
        return new byte[] {
                (byte)(value >>> 24),
                (byte)(value >>> 16),
                (byte)(value >>> 8),
                (byte)value};
}
	public static int getSectionsToLoad(IELF elf, List<ISection> sections) {
		int total = 0;
		for (ISegment segment : elf.getSegments()) {
			if (segment.getType().equals(SegmentType.PT_LOAD)) {
				for (ISection s : segment.getSections()) {
					if (s.getSectionType().equals(SectionType.SHT_PROGBITS)) {
						sections.add(s);
						total += s.getSectionSize();
					}
				}
			}
		}
		return total;
	}
}
