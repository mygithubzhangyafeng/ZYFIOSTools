# ZYFIOSTools

remote: Support for password authentication was removed on August 13, 2021
https://blog.csdn.net/qq_41646249/article/details/119777084

#首次push github代码需要生成令牌 Generate token
之后使用：
git remote set-url origin https://<your_token>@github.com/<USERNAME>/<REPO>.git

<your_token>：换成你自己得到的token
<USERNAME>：是你自己github的用户名
<REPO>：是你的仓库名称
例如： https://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@github.com/mygithubzhangyafeng/ZYFIOSTools.git


#Swift 删除SceneDelegate
https://www.jianshu.com/p/917598588a69
1、删除SceneDelegate类文件
2、删除info.plist文件的Application Scene Manifest配置
3、AppDelegate类文件添加window属性 
var window:UIWindow?
4、删除AppDelegate类文件的UISceneSession相关代码

# source tree 如何忽略文件 
https://wenku.baidu.com/view/4fc47b39c6da50e2524de518964bcf84b9d52de8.html
忽略指定文件：直接写文件名

忽略文件夹：直接写文件夹路径，例：target或者target/ -> 忽略target下的所有文件

忽略某类型的文件：使用通配符*，例：*.class -> 忽略所有.class文件

步骤：
设置---高级---编辑忽略文件
忽略pod相关以填写
.xcworkspace
xcuserdata
*.lock
Pods

忽略规则的一些语法：
忽略.o和.a文件：
*.[oa]
忽略.b和.B文件，my.b除外：
★[bB]
!my.b
忽略dbg文件和dbg目录：
dbg
只忽略dbg目录，不忽略dbg文件：
dbg/
只忽略dbg文件，不忽略dbg目录：
dbg!
dbg/
只忽略当前目录下的dbg文件和目录，子目录的dbg不在忽略范围内：
/dbg
