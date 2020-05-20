/*
 *
 * Copyright (c) 2009 Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 */
 package com.altera.systemconsole.Avalon_Fast_Downloader;

import java.util.Collection;
import java.util.LinkedList;
import java.util.List;

import com.altera.systemconsole.core.ISystemConsole;
import com.altera.systemconsole.core.ISystemFilesystem;
import com.altera.systemconsole.core.ISystemNode;
import com.altera.systemconsole.jtag.INodeInfo;

/**
 * Task to search for SLD nodes to register a custom interface with.  This
 * is implemented to see if the node has already been registered so it can
 * be safely run repeatedly without affecting existing services.
 * 
 * @author cruben
 */
@SuppressWarnings("unqualified-field-access")
public class AvalonFastDownloaderSLDNodeDiscovery implements Runnable, ISystemNode.INodeListener {

	/** the manufacturer id associated with my node */
	public static final int MANUFACTURER_ID = 110;
	
	/** the node type id associated with my node */
	public static final int NODE_TYPE_ID = 134;


	private final ISystemNode deviceNode;
	
	/**
	 * Construct a task that will begin a search for SLD nodes supporting our 
	 * service starting from the given virtual filesystem location (which is 
	 * expected to be a device node).  It monitors the children of the device
	 * for changes so that if the device is reprogrammed a new search for nodes 
	 * associated with this service will be performed.
	 * @param deviceNode
	 */
	public AvalonFastDownloaderSLDNodeDiscovery(ISystemNode deviceNode) {
		this.deviceNode = deviceNode;
		this.deviceNode.addNodeListener(this);
	}
	
	/* (non-Javadoc)
	 * @see java.lang.Runnable#run()
	 */
	@Override
	public void run() {
		ISystemFilesystem fs = deviceNode.getInterface(ISystemFilesystem.class);
			Collection<ISystemNode> sldNodes = fs.findDescendantsByType(deviceNode, INodeInfo.class);
			List<ISystemNode> myNodes = new LinkedList<ISystemNode>();
			for (ISystemNode n : sldNodes) {
				INodeInfo info = n.getInterface(INodeInfo.class);
				if ((info.getManufacturerID() == MANUFACTURER_ID) && (info.getNodeID() == NODE_TYPE_ID)) {
					myNodes.add(n);
				}
			}
			addNodes(myNodes);
	}
	
	
	void addNodes(List<ISystemNode> nodes) {
		for (ISystemNode n : nodes) {
			AvalonFastDownloaderMemoryService pcs = n.getInterface(AvalonFastDownloaderMemoryService.class);
//			IMemoryService pcs = n.getInterface(IMemoryService.class);
//			IMemoryService
			if (pcs == null) {
				pcs = new AvalonFastDownloaderMemoryService(n);
			}
		}
	}

	void rescan() {
		ISystemConsole sysc = deviceNode.getInterface(ISystemConsole.class);
		sysc.execute(this);
	}
	
	/* (non-Javadoc)
	 * @see com.altera.systemconsole.core.ISystemNode.INodeListener#childrenAdded(com.altera.systemconsole.core.ISystemNode, java.util.List)
	 */
	@Override
	public void childrenAdded(ISystemNode node, List<ISystemNode> added) {
		rescan();
	}

	/* (non-Javadoc)
	 * @see com.altera.systemconsole.core.ISystemNode.INodeListener#childrenRemoved(com.altera.systemconsole.core.ISystemNode, java.util.List)
	 */
	@Override
	public void childrenRemoved(ISystemNode node, List<ISystemNode> removed) {
		rescan();
	}


}
