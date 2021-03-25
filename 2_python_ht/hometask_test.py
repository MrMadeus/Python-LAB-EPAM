from page_parser import PageParser as pp
from get_url_data import GetData as gd

#initial data

search_word = 'python'
words_for_compare = ['python', 'linux', 'flask']

# Test connection to the web site

def test_website_connection():
	assert pp.get_page('https://rabota.by/') != False
	assert pp.get_page('https://rabota.by/search/vacancy?area=1002&fromSearchLine=true&st=searchVacancy&text=Python') != False

#Test of search results for the word "shotgun"

def test_search_shotgun():
	assert gd.fail_search('shotgun') == True

#Test of ocurence of words

def test_ocurence():
	compare_average = gd.average_count(words_for_compare, search_word)
	for i in gd.get_links(search_word):
		compare_in_link = gd.count_words(i, words_for_compare)
		for k in words_for_compare:
			assert abs(compare_average[k] - compare_in_link[k]) == 1
