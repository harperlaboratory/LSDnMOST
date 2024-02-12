function SR_Cristae_v1(input, filename) {
 		setBatchMode(true);
        open(input + filename);
        parentname = File.getName(input);
  		outfinal = input + parentname + "_objects/";
  		File.makeDirectory(outfinal);

		// Set measurements before running script so everything is getting analyzed properly 
		run("Set Measurements...", "area mean modal min bounding fit shape feret's integrated area_fraction stack redirect=None decimal=3");
       	origname = getTitle;
       	
       	selectImage(origname);
       	
       	// duplicate mito signal, convolve back to WF resultion and use for mask
		run("Duplicate...", "duplicate");
		run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 4 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize stack");
		rename("mtConvolve");
		run("Duplicate...", "duplicate");
		run("Make Binary", "method=Huang calculate black");
		run("Fill Holes", "stack");
		rename("mtMask");

		// creaste smaller mito mask for masking IMS-matrix signal
		run("Duplicate...", "title=mtMaskerode duplicate");
		setOption("BlackBackground", true);
		run("Erode", "stack");

		// Create OMM mask by variance filtering of mt SR-signal 
		selectImage(origname);
		run("Duplicate...", "title=Var duplicate");
		run("Variance...", "radius=3 stack");
		run("8-bit");
		
		selectImage("mtMaskerode");
		imageCalculator("Subtract create stack", "Var","mtMaskerode");
		selectImage("Result of Var");
		rename("OMM");
		run("Merge Channels...", "c1=mtMaskerode c2=OMM create keep");
		rename("Merge_OMM-mtMaskErode");
		
		
		// create IMS signal by unsharp filtering SR mito and subtracting OMM signal
		// measure IMS signal after binary formation and filteirng
		selectImage(origname);
		run("Duplicate...", "title=IMS duplicate");
		run("Unsharp Mask...", "radius=3 mask=0.60 stack");
		run("8-bit");
		selectImage("mtMask");
		run("Invert", "stack");
		imageCalculator("Subtract create stack", "IMS","mtMask");
		selectImage("Result of IMS");
		rename("IMSclean");
		selectImage("OMM");
		run("Duplicate...", "title=OMMmask duplicate");
		run("Make Binary", "method=Huang calculate black");

		run("Variance...", "radius=3 stack");
		imageCalculator("Subtract create stack", "IMSclean","OMMmask");
		selectImage("Result of IMSclean");
		rename("Cristae");
		run("Duplicate...", "duplicate");
		run("Unsharp Mask...", "radius=3 mask=0.60 stack");
		run("Make Binary", "method=Moments calculate black");
		run("Measure Stack...");

       	// save IMS results as csv files
		mtIMS = origname + "mtIMS" + ".csv"; 
       	selectWindow("Results");
        saveAs("Results", outfinal + i+"_mtIMS_"+mtIMS);
     	run("Close");
     	
     	
     	// measure mtMask as background ratio for relative cristae occupancy 
		selectImage("mtMask");
		run("Invert", "stack");
		run("Measure Stack...");

       	// save IMS results as csv files
		mtmask = origname + "mtmask" + ".csv"; 
       	selectWindow("Results");
        saveAs("Results", outfinal + i+"_mtmask_"+mtmask);
     	run("Close");


		// save all channels as multi-stack composite for later inspection
		selectImage("Cristae");
		maskname1 = origname + "Cristae";
		saveAs("Tiff", outfinal + i+"_"+ maskname1);
		
		selectImage("IMSclean");
		maskname2 = origname + "IMSclean";
		saveAs("Tiff", outfinal + i+"_"+ maskname2);
		
		selectWindow("IMS");
		maskname3 = origname + "IMS";
		saveAs("Tiff", outfinal + i+"_"+ maskname3);
		
		selectWindow("OMMmask");
		maskname4 = origname + "OMMmask";
		saveAs("Tiff", outfinal + i+"_"+ maskname4);
		
		selectWindow("OMM");
		maskname5 = origname + "OMM";
		saveAs("Tiff", outfinal + i+"_"+ maskname5);
		
		selectWindow("mtMask");
		maskname6 = origname + "mtMask";
		saveAs("Tiff", outfinal + i+"_"+ maskname6);
		
     	//run("Close");
     	     	
        // close all windows        
   		//run("Close"); 
      run("Close All"); 

}

// call function and run macro
input = getDirectory ("Choose input folder");
list = getFileList(input);
for (i = 0; i < list.length; i++)
        SR_Cristae_v1(input, list[i]);
