 function ARMC1MTGTMRM_Ratio_v2(input, filename) {
 		setBatchMode(true);
        open(input + filename);
        parentname = File.getName(input);
  		outfinal = input + parentname + "_Evalv2/";
  		File.makeDirectory(outfinal);

		// Set measurements before running script so everything is getting analyzed properly 
		run("Set Measurements...", "area mean modal min bounding fit shape feret's integrated area_fraction redirect=None decimal=3");
		
       	origname = getTitle;
		run("8-bit");
		
		// Since TMRM signal is at later timepoints of differentiation cleaner, use this as mask for mito
		// dublicate first frame of 568nm (== TMRM) channel, create mito binay file from it for masking mito-only signal 
		run("Select All");
		name = getTitle();
		
		run("Duplicate...", "title=TMRMt1mask duplicate channels=1 frames=1");
		run("Enhance Contrast", "saturated=0.35");
		run("Convert to Mask");
		run("Fill Holes");
		run("Invert");



		// duplicate 488n, (== MTG) and 568nm (== TMRM) channels for image calculations 
		selectWindow(name);
		run("Duplicate...", "title=MTG duplicate channels=2");
		
		selectWindow(name);
		run("Duplicate...", "title=TMRM duplicate channels=1");
		
		// subtract MitoMask from both MTG and TMRM channles to get only mitochondria signal
		imageCalculator("Subtract create stack", "MTG","TMRMt1mask");
		rename("MTGmito");

		selectWindow(origname);
		imageCalculator("Subtract create stack", "TMRM","TMRMt1mask");
		rename("TMRMmito");
		
		
		// calculate 32-bit float image of TMRM divided by MTG mito signal only 
		// measure ratio intensities over stack
		imageCalculator("Divide create 32-bit stack", "TMRMmito","MTGmito");
		rename("Ratio_TMRM-MTG");
		run("Measure Stack...");


		// saves the ratio of TMRM-MTG in folder
		selectWindow("Ratio_TMRM-MTG");
		maskname = origname + "TMRM-MTG_RatioIMG";
		saveAs("Tiff", outfinal + i+"_"+ maskname);

		// save results as csv files
		csvname = origname + "TMRM-MTG_Ratio" + ".csv"; 
       	selectWindow("Results");
        saveAs("Results", outfinal + i+"_TMRM-MTG_Ratio_"+csvname);
		selectWindow("Results"); 
     	run("Close");
     	
        // close all windows        
   		run("Close"); 
      run("Close All"); 

}

// call function and run macro
input = getDirectory ("Choose input folder");
list = getFileList(input);
for (i = 0; i < list.length; i++)
        ARMC1MTGTMRM_Ratio_v2(input, list[i]);