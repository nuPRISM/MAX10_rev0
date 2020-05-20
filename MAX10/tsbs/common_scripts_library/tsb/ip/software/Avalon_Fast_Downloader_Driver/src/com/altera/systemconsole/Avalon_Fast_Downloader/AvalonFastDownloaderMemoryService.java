/**
 * 
 */
//temporarily commented out
package com.altera.systemconsole.Avalon_Fast_Downloader;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.altera.systemconsole.core.IAddress;
import com.altera.systemconsole.core.IRegion;
import com.altera.systemconsole.core.ISystemNode;
import com.altera.systemconsole.core.services.IMemoryService;
import com.altera.systemconsole.core.services.ISLDService;
import com.altera.systemconsole.internal.core.AddressSpace32;
import com.altera.systemconsole.internal.core.services.MemoryService;


/**
 * A memory service implementation that uses fasttransacto to perform Avalon
 * memory master transactions.
 * 
 * @author cruben
 */

/* Basically, when creating a memory service, you want to extend from MemoryService .  
 * Then, there should only be 4 methods to implement:
 *  constructor
 *  createRegion   this is the important one
 *  closeService
 *  openService
 */
@SuppressWarnings("nls")
public  class AvalonFastDownloaderMemoryService extends MemoryService implements IMemoryService{


	private boolean verify =false;
	private int offset =0;
	private boolean download =true;
	private boolean debug = false;

	private ISLDService sld;

	// Once you've extended MemoryService, you still need to implement a constructor
	public AvalonFastDownloaderMemoryService(ISystemNode node) {
		super(node);
		node.putInterface(IMemoryService.class, this);
		node.putInterface(AvalonFastDownloaderMemoryService.class, this);
	}
	
	// this is  custom stuff to control the advanced features of the driver
	public void set_params(boolean ver,boolean down,int offst, boolean dbug)
	{
		this.offset = offst;
		this.verify = ver;
		this.download = down;
		this.debug = dbug;
	}
	@Override
	// Once you've extended MemoryService, you still need to implement this
	public IRegion createRegion() {
		// I need to return an IRegion that represents my memory space.  See class below.
		return new AvalonFastDownloaderRegion("entire-space",0,Integer.MAX_VALUE);
	}
	/**
	 * Open the channel for service.  This means opening both an SLD
	 * hub and an SLD node.  Then create the input and output streams.
	 * 
	 * @throws Exception if the ISLDService cannot be located or if the
	 * ISLDService throws an exception when being opened.
	 */
	@Override
	// Once you've extended MemoryService, you still need to implement this
	protected void openService() throws Exception {
		sld = node.getInterface(ISLDService.class);
		if (sld == null) {
			throw new Exception("Unable to obtain ISLDService");
		}
		sld.open();
	}

	/**
	 * Close the channel, indicating its services are no longer needed.
	 * 
	 * @throws Exception
	 */
	@Override
	// Once you've extended MemoryService, you still need to implement this
	protected void closeService() {
		if (isOpen()) {
			try {
				sld.close();
			} catch (Exception e){
				// If there was an exception it's not like there is any further action that could be taken.
				// Just log the problem.
				Logger l = node.getInterface(Logger.class);
				l.log(Level.SEVERE, e.getMessage(), e);
			}
		}
	}

	// Memory servies does something by default but in the case we want to limit the size to 8 bites
	public TransferSize maximumPeekSize() {
		return TransferSize.TRANSFER_8;
	}

	// Memory servies does something by default but in the case we want to limit the size to 8 bites
	public TransferSize maximumPokeSize() {
		return TransferSize.TRANSFER_8;
	}

	// Create the IRegion by extending a AddressSpace32, which handles most of the stuff (including the RelativeAddress function) for me
	public class AvalonFastDownloaderRegion extends AddressSpace32 {

		// from AddressSpace 32, we still need to implement these 4 methods.
		public AvalonFastDownloaderRegion(String name, long start, int length) {
			// nothing special to do here, just tell me how big I am.
			super(name, start, length);
			this.initialized =0;
		}

		@Override
		public ByteOrder getByteOrder() {
			return ByteOrder.LITTLE_ENDIAN;
		}

		@Override
		public void read(IAddress address, ByteBuffer data) throws Exception {
			transmitBuffer(READ_MODE,address.getLowerValue(),data);			
		}

		@Override
		public void write(IAddress address, ByteBuffer data) throws Exception {
			transmitBuffer(WRITE_MODE,address.getLowerValue(),data);
		}

		// the very custom stuff below here

	
		public static final int FAST_JTAG_ID = 134;  // this is the final official one
		public static final int ALTERA_MFG_ID = 110;
		private static final int WRITE_MODE = 0x1;
		private static final int READ_MODE = 0x2;
		private static final int ADDRESS_MODE = 0x3;
		private static final int PRESET_ADDRESS_MODE = 0x4;

		static final int DEFAULT_POLL_RATE = 0;
		private int initialized =0;
		private int hw_shift =0;
	


		private int do_initialization() throws IOException {
			byte[] bytes;
			byte[] loopCaptureData = null;
		
			// first reset the address and then read it. 
			// see how much the read back is shifted. 
			bytes = new byte[5];  // allocate enough space for the entire read
			bytes[0] = 0x0;
			bytes[1] = 0x12;
			bytes[2] = 0x34;
			bytes[3] = 0x56;
			bytes[4] = 0x78;
			try{
				accessIR(PRESET_ADDRESS_MODE); // load the address with a default value
				accessIR(ADDRESS_MODE);  // now read the address
				loopCaptureData = accessDR(bytes); // this is where the real work gets done
				int one =loopCaptureData[0];// this one is a dummy 
				int two =loopCaptureData[1];
				int three =loopCaptureData[2];
				int four =loopCaptureData[3];
				int five =loopCaptureData[4];
				int total = (0xff000000&(two<<24)) + (0x00ff0000&(three<<16)) + (0x0000ff00&(four<<8)) + (0x000000ff&five);
				if (AvalonFastDownloaderMemoryService.this.debug){
					System.out.printf(" ADDRESS READ %s. 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n",loopCaptureData.toString(),one,two,three,four,five,total);//,Integer.getInteger(loopCaptureData.toString()),0x12345678/Integer.getInteger(loopCaptureData.toString()));
				}
				loopCaptureData = sld.accessDR(((bytes.length) * 8), bytes, 0); // this is where the real work gets done
				one =loopCaptureData[0];// this one is a dummy 
				two =loopCaptureData[1];
				three =loopCaptureData[2];
				four =loopCaptureData[3];
				five =loopCaptureData[4];
				total = (0xff000000&(two<<24)) + (0x00ff0000&(three<<16)) + (0x0000ff00&(four<<8)) + (0x000000ff&five);
				if (AvalonFastDownloaderMemoryService.this.debug){
					System.out.printf(" ADDRESS READ %s. 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n",loopCaptureData.toString(),one,two,three,four,five,total);//,Integer.getInteger(loopCaptureData.toString()),0x12345678/Integer.getInteger(loopCaptureData.toString()));
				}
				int i;
				for( i=0;i<16;i++){
					if (total == 0x12345678<<i){
						hw_shift=i<<4;
						if (AvalonFastDownloaderMemoryService.this.debug)
							System.out.printf(" ********** Shift of %d needed ***********\n",i);
					}
				}

				
					initialized = 1;
				return 1;
			}catch (Exception e) {
				throw new IOException("SLD accessIR failure: " + e.getMessage());
			}
		}
		/* here is where all the real work gets done.
		 * the mode is either READ_MODE or WRITE_MODE
		 * the address is a physical address to write or read the data
		 * the buff contains data to be written or the location of where the data is to be placed. 
		 */
		public int transmitBuffer(int mode,long address,ByteBuffer buff) throws IOException {
		int n = buff.remaining();	// how many bytes are left
			int Error=0;
			try {
				synchronized (this) {// what do I do here this is a problem
					AvalonFastDownloaderMemoryService.this.sld.lock(20000);
					try{
						// first thing to do is see if this has been initialized if not we need to do it. 
						if(initialized ==0)
							do_initialization();
				
						if( mode == READ_MODE) // I have been asked to read 
						{
							setAddress(address);
							accessIR(READ_MODE);  // now change the mode to read
							// read 2 extra bytes because there is a read latency of 2 bytes
							accessDR((n+2) * 8, null, 16, buff); // this is where the real work gets done

							if (AvalonFastDownloaderMemoryService.this.debug){
								System.out.printf("reading from address=0x%x length=0x%x endaddress=0x%x\n",address+offset,buff.remaining(),address+offset + buff.remaining());  
								}
						}
						else  // write mode
						{
							// diagnostics printout can be removed
							if (AvalonFastDownloaderMemoryService.this.debug){
							System.out.printf("writing to address=0x%x length=0x%x endaddress=0x%x\n",address+offset,buff.remaining(),address+offset + buff.remaining());  
							}
							// by default we are downloading
							if(AvalonFastDownloaderMemoryService.this.download)
							{
								//           	  			long start = System.currentTimeMillis();

								setAddress(address);
								
								accessIR(this.hw_shift+WRITE_MODE); //set the write mode
								
								int mark = buff.position();
								ByteBuffer read = null;//ByteBuffer.allocateDirect(n);
								if( this.hw_shift == 0) // if there is a shift then i would have to shift all the data coming back 
														// this is a lot of work which I don't want to do right now. 
								{
									accessDR(n * 8, buff, 0, read); // now push the data
								}
								else {
									accessDR(n * 8, buff, 0, null); // now push the data with no read back. 
								}
							
								//now compare the in array with the out array to see if they are equal
								if (read != null) {
									read.flip();
									byte[] loopCaptureData = new byte[read.remaining()];
									read.get(loopCaptureData);

									Error=0;
									// when comparing make sure the first two bytes are skipped and we can't actually see the last two
									for(int i=0;i<n-2;i++){
										if( buff.get(mark + i) != loopCaptureData[i+2]){
											Error ++;
											System.err.printf("Error in loopback data at address 0x%x, was 0x%x expected 0x%x\n",address +offset+ i,loopCaptureData[i+2], buff.get(i));
											if( Error>50) // only printout 50 errors
											{
												System.err.printf("Too many Errors exiting\n");
												break;
											}
										}
									}	
								}
							}
							if(AvalonFastDownloaderMemoryService.this.verify)
							{
								// now do the read of the data. 
								n=n+2; // when you read back the data you need 2 extra bytes.
								Error=0;
								byte[]  dbytes = new byte[n];
								setAddress(address);
								accessIR(READ_MODE);  // now the data
								byte[] loopCaptureDataR = accessDR(dbytes);
								for(int i=0;i<n-2;i++){
									if( buff.get(i)!= loopCaptureDataR[i+2]){
										Error ++;
										System.err.printf("Error in readback data at address 0x%x, was 0x%x expected 0x%x i=%d\n",address + offset + i,loopCaptureDataR[i+2], buff.get(i),i);
										if( Error>50)
										{
											System.err.printf("Too many Errors exiting\n");
											break;
										}	
									}	
								}
								if(Error ==0)  System.out.printf("	Verified\n");  	     	        
							}
						}// end write mode
						return Error;
					}finally {
						AvalonFastDownloaderMemoryService.this.sld.unlock();
					}
				} 
			}catch (Exception e) {
				throw new IOException("SLD accessDR failure: " + e.getMessage());
			}
		}	
		private void setAddress(long address) throws Exception {
			address += AvalonFastDownloaderMemoryService.this.offset; // add in the optional offset
			
			accessIR(this.hw_shift+ADDRESS_MODE); // change mode to load the address

			byte[] addressBytes = longToByteArray(address); // convert to bytes
			AvalonFastDownloaderMemoryService.this.sld.accessDR(4 * 8, addressBytes, 0); // send the address
		}
		
		private byte[] longToByteArray(long value) {
			return new byte[] {
					(byte)(value >>> 24),
					(byte)(value >>> 16),
					(byte)(value >>> 8),
					(byte)value};
		}
		
		private void accessIR(int num) throws Exception {
			AvalonFastDownloaderMemoryService.this.sld.accessIR(num, 0);
		}
		
		private byte[] accessDR(byte[] writeBits) throws Exception {
			byte[] result = new byte[writeBits.length];
			result = AvalonFastDownloaderMemoryService.this.sld.accessDR(writeBits.length * 8, writeBits, 0);
			return result;
		}
		
		private void accessDR(int numBits, ByteBuffer write, int readOffset, ByteBuffer read) throws Exception {
			int bytes = numBits/8;
			byte[] result = new byte[bytes]; 
			byte[] thebytes = new byte[bytes];			// need to convert the ByteBuffere to byte[]
			write.get(thebytes, 0, write.remaining());

			result = AvalonFastDownloaderMemoryService.this.sld.accessDR(numBits, thebytes, 0);
			if ( read != null ){	// check to see if want read back. 
				read.flip();
				read.put(result,readOffset/8,read.remaining());// need to whack off the offset
			}
	
		}

	}
}
