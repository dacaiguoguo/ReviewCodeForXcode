# ReviewCodeForXcode
---

## What is this?

Review code is so important for developing, but it is really painful with Xcode. Now, you can commit review to your reviewBoard service in Xcode. You can just click the review button beside the cancel button in commit code window.

1.install RBTools with python setup.py install
```
git clone https://github.com/dacaiguoguo/rbtools.git
```
simply run the following as root:
```
python setup.py install
```
2.fix username & password `ReviewCodeConfig.plist` & combine ReviewCode

3.restart Xcode

## License

ReviewCodeForXcode is published under MIT License. See the LICENSE file for more.

Todo:
1.svn 版本不一致不行  
2.工程目录里有中文不行？   
3.xcode-select 未指定，或者指定的是错误的也不行  
4.Xcode名字不是Xcode的时候需要修改工程配置  
5.完善Readme  

