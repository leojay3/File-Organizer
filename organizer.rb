Shoes.app(title: "File Organizer", width: 500, height: 500, resizable: true) do


	def organize
	   	search1 = Hash.new
	   	search2 = Hash.new
	   	search3 = Hash.new
	   	sorted_search1 = []
	   	sorted_search2 = []
	   	sorted_search3 = []
	   	resume = Hash.new
	   	file_added = []
	   	file_name = []
	   	added_file = Hash.new
	   	count = 0
	   
		list_place = nil
		count_place = nil
		result_place = nil
   		word1 = ""
   		word2 = ""
   		word3 = ""
   		sort = word1
   		type = ""

   		#This function is used create the hash tables values for what is being search in the file
		def search_builder(file_added, word)
		    file_data = File.read(file_added)
		    file_2data = File.read(file_added).split("\n")
			per = "#{word}: can not find"

			if file_data.downcase.include?(word.downcase)

				for j in 0..file_2data.length-1
				    if file_2data[j].downcase.include?(word.downcase)
						per = file_2data[j].downcase

						if per.include?(":")
						    per = per.capitalize

						elsif per.downcase.include?("#{word.downcase}")
						    per = "#{word}: found"
						end
					end
				end
			end
			return per
		end

		# This function is used to create the hash values of what will be found in the resume using regex
		def resume_builder(file_2data, regex)
			per = "Not Found"

			for j in 0..file_2data.length-1
				if file_2data[j].match(regex)
					per = file_2data[j]
					per = per.split("  ")[0]
					return per
				end
			end
			return per
		end

   		caption "What are you looking for? "
		@el = edit_line do |e|
      		word1 = e.text.downcase
    	end 

    	para"\n\n"
    	caption "What are you looking for? "
    	@al = edit_line do |e|
      		word2 = e.text.downcase
    	end

    	para"\n\n"
    	caption "What are you looking for? "
    	@bl = edit_line do |e|
      		word3 = e.text.downcase
    	end

    	#this creates a button that allows the user to add files from their folder
    	flow do
			button "Add Files" do
		    	filename = ask_open_file
		    	file_added.push(filename)
			    name = filename.split("/")
			    file_name.push(name[name.length-1]+"\n")
			    added_file[name[name.length-1]] = filename 
			    
			    list_place.replace file_name
				count = count + 1
				count_place.replace "Files added #{count} "
			 end

			 #Clears all of the hashes and arrays to do a new search if they want to
			 button "Clear Files" do
		   		search1 = Hash.new
		   		search2 = Hash.new
		   		search3 = Hash.new
		   		sorted_search1 = []
		   		sorted_search2 = []
		   		sorted_search3 = []
		   		resume = Hash.new

		   		file_added = []
		   		file_name = []
		   		added_file = Hash.new

		   		count = 0
		   		list_place.replace file_name
		   		count_place.replace "Files added #{count} "
		   	end

		   	#Give the user an option if what they are searching for is either a resume or other type of file
		   	para "Choose type of file:"
	  		list_box :items => ["Other", "Resume"],
	           	:width => 120,
	            :choose => "Other" do |list|
	    			type = list.text
	    			
					if type == "Resume"
						for i in 0..file_added.length-1 do
			    			file_data = File.read(file_added[i])
			    			file_2data = File.read(file_added[i]).split("\n")
			    			
			    			resume["name:#{file_name[i]}"] = file_2data[0]
			    			resume["email:#{file_name[i]}"] = resume_builder(file_2data, /\A[a-z0-9\+\-_\.]+@[a-z\d\-.]+\.[a-z]+\z/i)
			    			resume["phone:#{file_name[i]}"] = resume_builder(file_2data, /^\(\d{1,3}\)\s\d{1,3}\-\d{1,4}$/)
			    		end					
					end
	  			end
  			end

		button "Submit" do
		  	for i in 0..file_added.length-1 do

		    	search1[file_name[i]] = search_builder(file_added[i], word1)
		    	search2[file_name[i]] = search_builder(file_added[i], word2)
		    	search3[file_name[i]] = search_builder(file_added[i], word3)
		    	
		    end
		    sorted_search1 = search1.sort_by {|k, v| v}
		    sorted_search1 = sorted_search1.reverse
		    sorted_search2 = search2.sort_by {|k, v| v}
		    sorted_search2 = sorted_search2.reverse
		    sorted_search3 = search3.sort_by {|k, v| v}
		    sorted_search3 = sorted_search3.reverse

		   	added_file.each{|file_name, file_location|
		   		added_file[file_name] = link("#{file_name}", click: Proc.new { window do para File.read(file_location) end})
			}

			#creates a new window that displays the information
		    window do

		    	#this function is used to display the result in the new window
			    def result_builder(type, sort, sorted_search, resume, search1,search2)
		   			result = ""
					sorted_search.each do |filenames,bol|

						if type == "Resume"
			       			result = result + "Name: #{resume["name:#{filenames}"]}, Email: #{resume["email:#{filenames}"]}, Phone: #{resume["phone:#{filenames}"]}\n"
			       		end

						result = result + "#{bol} \n #{search1[filenames]} \n #{search2[filenames]} \n in file: #{filenames}\n" 
					end
					return result + "\n"
				end

				#creates a list of files that when pressed open a seperate window with the file information
		    	flow do
		    		caption "Files:\n"
					added_file.each{|fil, linkSite|
						para linkSite}
				end
				save = button "save"

		    	para "Choose to sort by:"
	   			box_place = list_box :items => [word1, word2, word3],
	     		:choose => word1 do |list|
	       			sort = list.text
	       			result = ""

	       			if sort == word1
	       				result = result_builder(type, sort, sorted_search1, resume, search2, search3)
						
					elsif sort == word2
						result = result_builder(type, sort, sorted_search2, resume, search1, search3)
					
					else
						result = result_builder(type, sort, sorted_search3, resume, search1, search2)
							
					end
					result_place.replace result

					#allows the user to save a txt file of the search
					save.click{
	       				file = File.open("Organizer_#{sort}.txt", "w")   
  						file.puts result
  						file.close	
					}			
	   			end

				flow do
					result_place = para ""
				end			
			end
		end

		stack margin_left: 10, margin_top: 10 do
   			count_place = para "Files added #{count} "
   			list_place = para file_name
   		end
	end
 organ = organize()
end






