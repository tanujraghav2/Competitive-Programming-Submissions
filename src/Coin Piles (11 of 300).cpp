/**
 *	Author: Tanuj Raghav <tanujraghav>
 *
 *	Created: Monday, January 02, 2023 	 16:34:59 IST
 *
 *	Problem: Coin Piles (11 of 300)
 *	Problem Statement: https://cses.fi/problemset/task/1754/
**/

#include<bits/stdc++.h>
using namespace std;

typedef long long ll;

class Problem{
	int a, b;
	public:
		void solution(){
			cin>>a>>b;
			if((a+b)%3==0&&a<=2*b&&b<=2*a)
				cout<<"YES";
			else
				cout<<"NO";
		}
};

int tc;

int main(){
	ios_base::sync_with_stdio(0); cin.tie(0);
	for(cin>>tc;tc--;cout<<"\n"){
		Problem i;
		i.solution();
	}
}