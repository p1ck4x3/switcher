import urllib2

COINWARZ_URL='http://www.coinwarz.com/cryptocurrency'

dat = urllib2.urlopen(COINWARZ_URL).read()

for l in dat.split('\n'):
	if l.find('width:48px;') != -1:
		pos = l.find('(')
		assert pos != -1, 'CoinWarz changed format.'
		coin_name = l[pos+1:pos+4]
		print coin_name,
