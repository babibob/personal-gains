#!/usr/bin/env python3

# import requests

# def get_ethereum_price():
#     url = "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=eur"
#     response = requests.get(url)
#     data = response.json()
#     if 'ethereum' in data and 'usd' in data['ethereum']:
#         return data['ethereum']['usd']
#     else:
#         return None

# if __name__ == "__main__":
#     ethereum_price = get_ethereum_price()
#     if ethereum_price:
#         print(f"Current Ethereum price: ${ethereum_price}")
#     else:
#         print("Failed to retrieve Ethereum price.")


import requests
url = 'https://api.coingecko.com/api/v3/simple/price'

currencies = "EUR", "USD"

for currency in currencies:
    params = {
            'ids': 'ethereum',
            'vs_currencies': currency
    }

    response = requests.get(url, params = params)

    if response.status_code == 200:
            data = response.json()
            eth_price = data['ethereum'][currency.lower()]

            print(f'{currency} == {eth_price}')
    else:
            print('Failed to retrieve data from the API')


# import requests
# url = 'https://api.coingecko.com/api/v3/simple/price'

# currencies = ['USD', 'EUR']

# for currency in currencies:
#     params = {
#             'ids': 'ethereum',
#             'vs_currencies': "${currency}"
#     }

#     response = requests.get(url, params = params)

#     if response.status_code == 200:
#             data = response.json()
#             eth_price = data['ethereum'][currency.lower()]
#             # eth_price = data['ethereum']['usd']
#             print(f'The price of Ethereum in ${currency} is ${eth_price}')
#     else:
#             print('Failed to retrieve data from the API')