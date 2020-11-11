Github ID를 검색하면 팔로워 정보를 보여주는 앱입니다.

## 기능
- github ID를 검색하여, 팔로워 데이터를 보여준다.
- 검색한 결과는 특정 키워드를 입력하면 필터링할 수 있다.
- 팔로워의 아이템을 클릭하면, 상세정보를 볼 수 있다.
- 팔로워 수가 없으면, empty view 상태로 보여준다.

## 사용한 기술
- 스토리보드를 사용하지 않고 코드로 UI를 구현하였습니다.
- iOS13에 소개된 `UICollectionViewDiffableDataSource`적용 하였습니다.
- 서치바에 키워드를 입력하면, 필터링 되어 결과를 보여줍니다.

##  스크린 샷
<img src = "img/searchVC.jpeg" width = "225">  <img src = "img/FollowerlistVC.jpeg" width = "225">  <img src = "img/UserInfoVC.jpeg" width = "225">  <img src = "img/FavoritesListVC.jpeg" width = "225"> <img src = "img/empty id.jpeg" width= "225"> <img src = "img/settings.jpeg" width = "225"><img src = "img/wrong id.jpeg" width = "225">


