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
/碰撞检测
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

