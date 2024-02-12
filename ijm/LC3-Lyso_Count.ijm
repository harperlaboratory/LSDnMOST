 function LC3LysoCount(input, filename) {
 		setBatchMode(true);
        open(input + filename);
        parentname = File.getName(input);
  		outfinal = input + parentname + "_objects/";
  		File.makeDirectory(outfinal);

		// Set measurements before running script so everything is getting analyzed properly 
		run("Set Measurements...", "area mean modal min bounding fit shape feret's integrated area_fraction stack redirect=None decimal=3");
       	
       	origname = getTitle;
       	//setOption("ScaleConversions", true);
		run("8-bit");

       	// CREATION OF OBJECT MASKS
		// duplicate nucleus channel for normalizing per cell
		selectWindow(origname);
		run("Duplicate...", "title=p62 duplicate channels=2");
		run("Subtract Background...", "rolling=10");
		setAutoThreshold("Intermodes dark no-reset");
		//run("Threshold...");
		setAutoThreshold("Moments dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		rename("p62");
		

		// duplicate HA channel, subtract background and make binay for measurements 
		selectWindow(origname);
		run("Duplicate...", "title=lysoMask duplicate channels=1");
		run("Gaussian Blur...", "sigma=2");
		setAutoThreshold("Moments dark no-reset");
		//run("Threshold...");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		rename("lysoMask");
		
		// copy LC3B channel and subtract background
		// the convert to binary file for counting 
		selectWindow(origname);
		run("Duplicate...", "title=LC3 duplicate channels=3");
		run("Subtract Background...", "rolling=10");
		setAutoThreshold("Intermodes dark no-reset");
		//run("Threshold...");
		setAutoThreshold("Moments dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		rename("LC3");


		// MEASUREMENTS OF OBJECTS
		// LC3B
		// measure LC3B objects and save 
		selectWindow("LC3");
		run("Analyze Particles...", "size=0.2-Infinity show=[Overlay Masks] display summarize");
			
		// save results of Lc3B measurements as csv files
		csvname1 = origname + "LC3B" + ".csv"; 
       	selectWindow("Results");
        saveAs("Results", outfinal + i+"_LC3B_"+csvname1);
     	run("Close");
     	    
     	    
     	 // LYSO   
     	 // measure Lamp1 objects and save 
		selectWindow("lysoMask");
		run("Analyze Particles...", "size=0.05-Infinity show=[Overlay Masks] display summarize");
			
		// save results of Lc3B measurements as csv files
		csvname2 = origname + "lyso" + ".csv"; 
       	selectWindow("Results");
        saveAs("Results", outfinal + i+"_lyso_"+csvname2);
     	run("Close");
     	
     	
     	// p62
		// measure Nuclear masks for normalization 
		selectWindow("p62");
		run("Analyze Particles...", "size=0.2-Infinity show=[Overlay Masks] display summarize");

		// save results as csv files
		csvname3 = origname + "p62" + ".csv"; 
       	selectWindow("Results");
        saveAs("Results", outfinal + i+"_p62_"+csvname3);
     	run("Close");	

        // close all windows        
   		run("Close"); 
      run("Close All"); 

}

// call function and run macro
input = getDirectory ("Choose input folder");
list = getFileList(input);
for (i = 0; i < list.length; i++)
        LC3LysoCount(input, list[i]);
