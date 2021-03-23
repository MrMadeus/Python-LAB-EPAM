import requests
from page_parser import page_parser as pp
from bs4 import BeautifulSoup

# Test connection to the web site

def get_page_status(url_in):
	url_in = url_in.rstrip()
	target = requests.get(url_in, headers={'User-Agent': 'Custom'})
	if target.status_code == 200:
		return True
	else:
		return False

def test_website_connection():
	assert get_page_status('https://rabota.by/') == True
	assert get_page_status('https://rabota.by/search/vacancy?area=1002&fromSearchLine=true&st=searchVacancy&text=Python') == True

#Test of search results for the word "shotgun"

def fail_search(search_word):
	search_url = 'https://rabota.by/search/vacancy?area=1002&fromSearchLine=true&st=searchVacancy&text=' + search_word
	search_page = pp.get_page(search_url)
	search_soup = BeautifulSoup(search_page, 'lxml')
	key = search_soup.find_all('h1')
	no_patern = 'ничего не надено'
	if str(key[0]).find(no_patern):
		return True
	else:
		return False

def test_search_shotgun():
	assert fail_search('shotgun') == True

#Test of ocurence of words

def count_words(job_url, search_words):
	job_page = pp.get_page(job_url)
	word_counter = {a: 0 for a in search_words}
	for i in range(len(job_page)):
		for w in search_words:
			if w.lower() == job_page[i:(i + len(w))].lower():
				word_counter[w] += 1
	return word_counter

def average_count(search_word, compare_words):
	start_url = 'https://rabota.by/search/vacancy?area=1002&fromSearchLine=true&st=searchVacancy&text='

	start_page = pp.get_page(start_url + search_word)
	start_soup = BeautifulSoup(start_page, 'lxml')
	vacancies = []
	for link in start_soup.find_all('a', href=True):
		if link['href'][0:18] == 'https://rabota.by/':
			vacancies.append(jobs(link['href'], search_words))
	sum_word_count = {a: 0 for a in search_words}
	c = 0
	for j in vacancies:
		for k, v in j.count_words().items():
			sum_word_count[k] += v
		print(j.link, ': ', j.count_words())
		c += 1
	for k, v in sum_word_count.items():
		sum_word_count[k] = v / c
	return sum_word_count

if __name__ == "__main__":
	main()