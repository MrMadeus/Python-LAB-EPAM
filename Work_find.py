import requests as req
import page_parser as pp
from bs4 import BeautifulSoup
#import re

class jobs:
	def __init__(self, link, s_w):
		self.link = link
		self.s_w = s_w
	def count_words(self):
		job_page = pp.get_page(self.link)
		word_counter = dict.fromkeys(self.s_w)
		for line in job_page:
			for i in range(len(line)):
				for w in self.s_w:
					if w == line[i:len(w)]:
						word_counter[w] += 1
		return word_counter

def main():
	start_url = 'https://rabota.by/search/vacancy?area=1002&fromSearchLine=true&st=searchVacancy&text='

	search_word = input('Enter search request: ')
	words = input('Enter words fon searching (1sr. 2nd, ...): ')
	search_words = words.split(', ')

	start_page = pp.get_page(start_url + search_word)
	start_soup = BeautifulSoup(start_page, 'lxml')
	vacancies = []
	for link in start_soup.find_all('a', href=True):
		if link['href'][0:18] == 'https://rabota.by/':
			vacancies.append(jobs(link['href'], search_words))
	for j in vacancies:
		print(j.link, ': ', j.count_words())

if __name__ == "__main__":
	main()