# DOTHE
Defense Of The Home保卫家园，用Swift 4写的一个简单的SpriteKit框架写的射击类小游戏

- [x]移动
- [x]发射子弹
- [x]自动发射子弹
- [x]背景音乐
- [x]子弹发射音乐
- [x]游戏结束音乐
- [x]碰撞检测
- [x]场景转换
- [x]帧缓存
- [x]血量
- [x]怪物死亡判断
- [x]怪物类型
- [x]得分算法
- [x]Swift 4
- [x]随机补给物品
- [x]拾取补给双子弹buf
- [x]双子弹时间限制
- [x]boss机制

![](/imgs/demo.png)

# 部分代码预览
```swift
//碰撞检测
extension GameScene {
    private func score(_ withType:SKTextureType) -> Int {
        if withType == .small {
            return 1
        }else if withType == .mid {
            return 2
        }else if withType == .big {
            return 3
        }else if withType == .boss {
            return 5
        }else {
            return 0
        }
    }
    //每一帧开始时，SKScene的-update:方法将被调用，参数是从开始时到调用时所经过的时间
    override func update(_ currentTime: TimeInterval) {
        //var toremoveArms = [SKSpriteNode]()
        for monster_bullet in monsterBullets {
            if monster_bullet.frame.intersects(hero.frame) {
                gameOver()
                return
            }
        }
        for monster in monsters {
            if monster.frame.intersects(hero.frame) {
                gameOver()
                return
            }
            for arm in arms {
                if arm.frame.intersects(monster.frame) {
                    //remove bullet
                    arm.removeFromParent()
                    let armindex = arms.index(of: arm)
                    if armindex != nil {
                        arms.remove(at: armindex!)
                    }
                    //refresh hp
                    if(monster.alive()) {
                        monster.hp -= 1
                        if monster.alive() {
                            continue
                        }
                    }
                    //if not alive, remove mosnter
                    monster.removeFromParent()
                    if monster == boss {
                        boss.removeAllActions()
                    }
                    let monsterindex = monsters.index(of: monster)
                    if monsterindex != nil {
                        monsters.remove(at: monsterindex!)
                    }
                    //refresh score
                    score += score(monster.type)
                    scorLb?.text = String(score)
                    refreshRecordIfNeed()
                }
            }
        }
        if supply.parent != nil {
            if supply.frame.intersects(hero.frame) {//拾取补给，双子弹模式
                supply.removeFromParent()
                removeAction(forKey: "supply_key")
                hero.buff = .doubleBullet
                let last = SKAction.wait(forDuration: 15)
                let reset = SKAction.run {
                    self.hero.buff = .none
                }
                let sequnce = SKAction.sequence([last,reset])
                run(sequnce, withKey: "supply_key")
            }
        }
    }
}
```

```swift
private func shoot() {
        guard hero.shouldShoot else {
            return
        }
        if hero.buff == .none {
            let armsNode = SKElementNode.init(type: .bullet)
            //从英雄位置发射飞镖
            armsNode.position = hero.position
            //点击位置
            addChild(armsNode)
            arms.append(armsNode)
            //计算飞镖实际移动距离
            let distance = size.height - armsNode.position.y
            let speed = size.height
            //飞镖移动所需时间
            let duration = distance/speed
            let moveAction = SKAction.moveTo(y: size.height, duration: TimeInterval(duration))
            weak var wkarms = armsNode
            weak var wkself = self
            //同时执行2个action
            let group = SKAction.group([moveAction,armSoundAction])
            armsNode.run(group, completion: {
                wkarms?.removeFromParent()
                let index = wkself?.arms.index(of: wkarms!)
                if index != nil {
                    wkself?.arms.remove(at: index!)
                }
            })
        }else if hero.buff == .doubleBullet {
            let bullet1 = SKElementNode.init(type: .bullet)
            bullet1.position = .init(x: hero.position.x - hero.size.width/4, y: hero.position.y)
            addChild(bullet1)
            let bullet2 = SKElementNode.init(type: .bullet)
            bullet2.position = .init(x: hero.position.x + hero.size.width/4, y: hero.position.y)
            addChild(bullet2)
            arms.append(bullet1)
            arms.append(bullet2)
            
            //计算飞镖实际移动距离
            let distance = size.height - bullet1.position.y
            let speed = size.height
            //飞镖移动所需时间
            let duration = distance/speed
            let moveAction = SKAction.moveTo(y: size.height, duration: TimeInterval(duration))
            weak var wkbullet1 = bullet1
            weak var wkbullet2 = bullet2
            weak var wkself = self
            //同时执行2个action
            let group = SKAction.group([moveAction,armSoundAction])
            bullet1.run(group, completion: {
                wkbullet1?.removeFromParent()
                let index = wkself?.arms.index(of: wkbullet1!)
                if index != nil {
                    wkself?.arms.remove(at: index!)
                }
            })
            bullet2.run(moveAction, completion: {
                wkbullet2?.removeFromParent()
                let index = wkself?.arms.index(of: wkbullet2!)
                if index != nil {
                    wkself?.arms.remove(at: index!)
                }
            })
        }else{
            
        }
    }
```

```swift
private func addMonsters() {
        weak var wkself = self
        //自动无限循环产生怪兽
        let addMonsterAction = SKAction.run {
            wkself?.generateMonster()
        }
        let waitAction = SKAction.wait(forDuration: 0.8)
        let bgSequence = SKAction.sequence([addMonsterAction,waitAction])
        let repeatAction = SKAction.repeatForever(bgSequence)
        //无限循环添加Monster
        run(repeatAction)
    }
    private func generateMonster() {
        showSupplyeIfNeed()
        if boss.parent != nil {
            return
        }
        if totalGeneratedMonsterCount % 80 == 0 && totalGeneratedMonsterCount > 0 {
            bossShow()
            return
        }
        weak var wkself = self
        //计算精灵的移动时间
        let minduration:Int = 4
        let maxduration:Int = 5
        var duration = Int(arc4random_uniform((UInt32(maxduration - minduration)))) + minduration
        var bulletCount = 0
        //计算怪物的出现位置
        var enemyType:SKTextureType = .small
        if totalGeneratedMonsterCount == 0 {
            enemyType = .small
        }else if totalGeneratedMonsterCount % 10 == 0 && totalGeneratedMonsterCount % 20 != 0 {
            enemyType = .mid
            duration = maxduration
            bulletCount = 2
        }else if totalGeneratedMonsterCount % 20 == 0 {
            enemyType = .big
            duration = maxduration
            bulletCount = 4
        }else{
            enemyType = .small
        }
        let monster = SKElementNode.init(type: enemyType)
        let minx:Int = Int(monster.size.width / 2)
        let maxx:Int = Int(size.width - monster.size.width / 2)
        let gapx:Int = maxx - minx
        let xpos:Int = Int(arc4random_uniform(UInt32(gapx))) + minx
        monster.position = .init(x: CGFloat(xpos), y: (size.height + monster.size.height/2))
        addChild(monster)
        totalGeneratedMonsterCount += 1
        monsters.append(monster)
        //精灵发射子弹
        if bulletCount > 0 {
            monsterShoot(monster: monster, bulletCount: bulletCount, shootDuration: 0.5, dismisDuration: duration)
        }
        //移动
        let moveAction = SKAction.moveTo(y: -monster.size.height/2, duration: TimeInterval(duration))
        //移除
        let removeAction = SKAction.run {
            monster.removeFromParent()
            let index = wkself?.monsters.index(of: monster)
            if index != nil {
                wkself?.monsters.remove(at: index!)
            }
            //end game
            wkself?.gameOver()
        }
        //顺序执行2个action，先移动，后移除
        monster.run(SKAction.sequence([moveAction,removeAction]))
    }
```
