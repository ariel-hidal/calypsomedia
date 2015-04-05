require 'flickraw'

# app authentication:
FlickRaw.api_key = '34bc8c3011fd7a09667b2ef95e490324'
FlickRaw.shared_secret = 'd30c7a5dd03a67b6'

# user authentication
flickr.access_token = '72157651275573440-4fd35b6923afdbb3'
flickr.access_secret = '5f4f273105776060'

# From here you are logged:
login = flickr.test.login
puts "You are now authenticated as #{login.username}"


# this variable gets us a list of all photosets for a given account
set = flickr.photosets.getList

# we generate two arrays, one with the id of every photoset
# and another with every title
set_ids = []
set_titles = []

puts 'Gathering photoset information'

# redefine id, secret in terms of set. We need these to get info
# for a specific set.
i = 0
while i < (set.total)
  id     = set[i].id
  secret = set[i].secret
  title = set[i].title
  info = flickr.photosets.getInfo(:photoset_id => id, :secret => secret)
  set_ids.push(info.id)
  set_titles.push(info.title)
  i += 1
end

# inner only exists to create a 2d array. we output as follows:
# inner = ["photoset title", urls]. Then we push this into the
# photo array and clear inner to [] and do it again.
inner = []
photo = []

puts "photoset information gathered.
Gathering information for individual photos"

#We have a double loop so that we can loop through every picture in a
#photoset and also loop through every photoset
i = 0
while i < set.total
  photo_data = flickr.photosets.getPhotos(:photoset_id => set_ids[i], :user_id => "69742904@N03").photo
  n = flickr.photosets.getPhotos(:photoset_id => set_ids[i], :user_id => "69742904@N03").total
  n = n.to_i
  i1 = 0
  while i1 < n
    id = photo_data[i1].id
    secret = photo_data[i1].secret
    id_from_arr = flickr.photos.getInfo(:photo_id => id)
    urls = FlickRaw.url_b(id_from_arr)
    inner.push(set_titles[i])
    inner.push(urls)
    photo.push(inner)
    inner = []
    i1 += 1
  end
  i+=1
end

puts "photo information gathered. Generating front page links"

#now we generate frontpage img links formatted in html
front_page_links = ""

i = 0
while i < set_titles.length
  if set_titles[i] != 'Work'
    front_page_links = front_page_links + "<li><a href=\"#{set_titles[i]}.html\">#{set_titles[i]}</a></li>" + "\n"
  else
    front_page_links = front_page_links
  end
  i+=1
end


puts "Links generated. Writing links to frontpage"

# This is prewritten html template for all pages.
# The generated album titles are concatenated as
# links.
raw_template = IO.read('html_template.html')
template = raw_template.gsub "ADD_LINKS_HERE_PLEASE", front_page_links

puts "Links written. Now Generating photoset images."

#loop output for every album
i1 = 0
while i1 < set_titles.length
  album_images = ""
  i2 = 0
  while i2 < photo.length
    if (photo[i2][0] == set_titles[i1])
      if album_images == ""
        album_images = "<img src=\"#{photo[i2][1]}\" />" + "\n"
      else
        album_images = album_images + "<img class=\"clear\" src=\"#{photo[i2][1]}\" />" + "\n"
      end
    else
      album_images = album_images
    end
    i2+=1
  end
  html_album = template.gsub "ADD_IMGS_HERE_PLEASE", album_images
  if set_titles[i1] == "Work"
    html_name = "Index.html"
  else
    html_name = "#{set_titles[i1]}.html"
  end
  html_file = File.open(html_name, "w")
  html_file.puts(html_album)
  puts "#{html_name} generated and written!"
  i1+=1
end

puts "All Done!"
