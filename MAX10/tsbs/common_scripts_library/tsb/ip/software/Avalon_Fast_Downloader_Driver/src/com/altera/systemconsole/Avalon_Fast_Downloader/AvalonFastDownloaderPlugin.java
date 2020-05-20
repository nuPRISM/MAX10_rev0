/*
 *
 * Copyright (c) 2009 Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 */
 package com.altera.systemconsole.Avalon_Fast_Downloader;

import java.util.Collection;

import com.altera.systemconsole.core.ISystemConsole;
import com.altera.systemconsole.core.ISystemFilesystem;
import com.altera.systemconsole.core.ISystemNode;
import com.altera.systemconsole.core.SystemPluginProvider;
import com.altera.systemconsole.core.ISystemFilesystem.WellKnownLocation;
import com.altera.systemconsole.jtag.IJtagDevice;

/**
 * This is intended to be a simple example of how one might write a 
 * system console plugin to add new services or provide alternative 
 * implementations of existing services.
 * <p>
 * What causes this class to be considered during discovery is the
 * file 
 * <code>META-INF/services/com.altera.systemconsole.core.SystemPluginProvider</code>
 * with the fully qualified name of this class on one of the lines.
 * In addition, the files of the project should be in the classpath in
 * order to be discovered.
 * 
 * @author Tim Prinzing
 */
@SuppressWarnings({"unqualified-field-access"})
public class AvalonFastDownloaderPlugin extends SystemPluginProvider {

	/**
	 * This method gets called when system console installs the plugin.  This is
	 * normally done when {@link ISystemConsole#start(boolean)} is called.  The jtag
	 * plugin may not have run yet so we add a task to the queue to go look for SLD nodes
	 * to decorate with our customized service.
	 * 
	 * @see com.altera.systemconsole.core.ISystemPlugin#install(com.altera.systemconsole.core.ISystemConsole)
	 */
	@Override
	public void install(ISystemConsole sys) throws Exception {
		installed = true;
		this.sysc = sys;
		sysc.execute(new DeviceDiscovery());
	}

	/* (non-Javadoc)
	 * @see com.altera.systemconsole.core.ISystemPlugin#isInstalled()
	 */
	@Override
	public boolean isInstalled() {
		return installed;
	}

	/* (non-Javadoc)
	 * @see com.altera.systemconsole.core.ISystemPlugin#uninstall(com.altera.systemconsole.core.ISystemConsole)
	 */
	@Override
	public void uninstall(ISystemConsole sys) throws Exception {
		installed = false;
		
	}
	
	ISystemConsole sysc;
	private boolean installed;
	
	class DeviceDiscovery implements Runnable {

		@Override
		public void run() {
			ISystemFilesystem fs = sysc.getVirtualFilesystem();
			ISystemNode connections = fs.getConnectionPoint(WellKnownLocation.connections);
			Collection<ISystemNode> devices = fs.findDescendantsByType(connections, IJtagDevice.class);
			for (ISystemNode devNode : devices) {
				Runnable task = new AvalonFastDownloaderSLDNodeDiscovery(devNode);
				task.run();
			}
		}
		
	}
}
