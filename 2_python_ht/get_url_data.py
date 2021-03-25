from page_parser import PageParser as pp
from bs4 import BeautifulSoup

class GetData:

	@staticmethod
	def count_words(job_url, search_words):
		job_page = pp.get_page(job_url)
		word_counter = {a: 0 for a in search_words}
		for i in range(len(job_page)):
			for w in search_words:
				if w.lower() == job_page[i:(i + len(w))].lower():
					word_counter[w] += 1
		return word_counter
	
	@staticmethod	
	def get_links(search_word):
		start_url = 'https://rabota.by/search/vacancy?area=1002&fromSearchLine=true&st=searchVacancy&text='

		start_page = pp.get_page(start_url + search_word)
		start_soup = BeautifulSoup(start_page, 'lxml')
		vacancies = []
		for link in start_soup.find_all('a', href=True):
			if link['href'][0:18] == 'https://rabota.by/':
				vacancies.append(link['href'])
		return vacancies

	@staticmethod
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

	@staticmethod
	def average_count(compare_words, search_word):
		sum_word_count = {a: 0 for a in compare_words}
		c = 0
		for j in GetData.get_links(search_word):
			for k, v in GetData.count_words(j, compare_words).items():
				sum_word_count[k] += v
			c += 1
		for k, v in sum_word_count.items():
			sum_word_count[k] = round(v / c)
		return sum_word_count