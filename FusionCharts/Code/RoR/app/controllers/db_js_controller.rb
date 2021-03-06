class DbJsController < ApplicationController

  def index
=begin  
	'In this example, we show a combination of database + JavaScript rendering using FusionCharts.
	
	'The entire app (page) can be summarized as under. This app shows the break-down
	'of factory wise output generated. In a pie chart, we first show the sum of quantity
	'generated by each factory. These pie slices, when clicked would show detailed date-wise
	'output of that factory.
	
	'The XML data for the pie chart is fully created in RoR at run-time. Rails interacts
	'with the database and creates the XML for this.
	'Now, for the column chart (date-wise output report), we do not submit request to the server.
	'Instead we store the data for the factories in JavaScript arrays. These JavaScript
	'arrays are rendered by our RoR Code (at run-time). We also have a few defined JavaScript
	'functions which react to the click event of pie slice.
	
	'We've used an mysql database. 
	'It just contains two tables, which are linked to each other. 
	
	'Before the page is rendered, we need to connect to the database and get the
	'data, as we'll need to convert this data into JavaScript variables.
	
	'The following string will contain the JS Data and variables.
	'This string will be built in ruby and rendered at run-time as JavaScript.
=end  
	
	@jsVarString1 = ""
	
	#Database Objects oRs, oRs2, strQuery, indexCount
	
	indexCount = 0
	
	oRs = Factorymaster.find(:all)
	
	oRs.each do |recordset1|
		indexCount = indexCount + 1
=begin		
		Create JavaScript code to add sub-array to data array
		'data is an array defined in JavaScript (see below)
		'We've added \t + \n to data so that if you View Source of the
		'output HTML, it will appear properly. It helps during debugging
=end    
		@jsVarString1 = @jsVarString1 + "\t \t"+  "data[" + indexCount.to_s + "] = new Array();" + "\n"
		##strQuery = "select * from factoryoutputs where FactoryId=" + recordset1.FactoryId.to_s + " order by DatePro Asc"
    oRs2 = Factoryoutput.find(:all,:conditions=>["FactoryId=?",recordset1.FactoryId.to_s], :order => 'DatePro ASC')
		oRs2.each do |recordset2|
			#Put this data into JavaScript as another nested array.
			#Finally the array would look like data[factoryIndex][i][dataLabel,dataValue]
			@jsVarString1 = @jsVarString1 + "\t \t"  +   "data[" + indexCount.to_s + "].push(new Array('" + recordset2.DatePro.strftime('%d') + "/" + recordset2.DatePro.strftime('%m') + "'," + recordset2.Quantity.to_s + "));" + "\n"
		end
	end
  
  		
	#Initialize the Pie chart with sum of production for each of the factories
	#strXML will be used to store the entire XML document generated
	strXML =''
	
	#Re-initialize Index
	indexCount=0
	
	#Generate the chart element
	strXML = "<chart caption='Factory Output report' subCaption='By Quantity' pieSliceDepth='30' showBorder='1' formatNumberScale='0' numberSuffix=' Units' >"
	
	#Move back to first index of the factory master recordset
		
	oRs.each do |recordset1|
		#Update index count - sequential
		indexCount = indexCount + 1
		@oRs2 = Factoryoutput.find(:all,:conditions=>["FactoryId=?",recordset1.FactoryId.to_s])
     recordcount = @oRs2.length
     count = 0
     quantity = 0
     while count < recordcount
       quantity = quantity + @oRs2[count][:Quantity].to_i
       count = count + 1
     end
     #puts quantity
    #Generate <set label='..' value='..'/>		
    factoryid = ""
    @oRs2.each do |recordset2|
      if factoryid != recordset2.FactoryId
		strXML = strXML + "<set label='" + recordset1.FactoryName + "' value='" + quantity.to_s + "' link='javaScript:updateChart(" + indexCount.to_s + ")'/>"
      end
      factoryid = recordset2.FactoryId
		#strXML = strXML + "<set label='" + recordset.FactoryName + "' value='" + recordset2.Quantity.to_s + "' />"
    end
	end
	#Finally, close <chart> element
	strXML = strXML + "</chart>"
	
	
	#Create the chart - Pie 3D Chart with data from strXML
	@chart1= renderChart("/FusionCharts/Pie3D.swf", "", strXML, "FactorySum", 500, 250, false, false)
@chart2=renderChart("/FusionCharts/Column2D.swf?ChartNoDataText=Please select a factory from pie chart above to view detailed data.", "", "<chart></chart>", "FactoryDetailed", 600, 250, false, false)
  
    end
end