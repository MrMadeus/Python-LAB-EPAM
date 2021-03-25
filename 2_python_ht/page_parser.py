import requests

class PageParser:
	def get_page(url_in):
		url_in = url_in.rstrip()
		target = requests.get(url_in, headers={'User-Agent': 'Custom'})
		if target.status_code != 200:
			return False
		page = target.text
		return page
