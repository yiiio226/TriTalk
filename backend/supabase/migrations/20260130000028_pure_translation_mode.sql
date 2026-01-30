-- Migration: Pure Translation Mode - 场景内容完全多语言化
-- Purpose: 
--   1. Add initial_message, ai_role, user_role translations to all languages in translations JSONB
--   2. Remove redundant text columns from standard_scenes (title, description, initial_message, goal, ai_role, user_role)
--   3. Update scene generation trigger to use target_lang for ALL fields
--      (title, description, goal, initial_message, ai_role, user_role)
--      This provides a fully immersive learning experience in the target language
-- Reference: docs/multi_language_support.md Sections 7 & 8

-- ============================================
-- Step 1: Update translations JSONB with initial_message, ai_role, user_role
-- ============================================
-- Note: We need to add translations for initial_message, ai_role, and user_role
-- to all 9 supported languages for all 13 standard scenes

-- 1. Order Coffee (a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Order Coffee", "description": "Order a coffee", "goal": "Order a coffee", "initial_message": "Hi! What can I get for you today?", "ai_role": "Barista", "user_role": "Customer"},
  "en-GB": {"title": "Order Coffee", "description": "Order a coffee", "goal": "Order a coffee", "initial_message": "Hello! What can I get for you today?", "ai_role": "Barista", "user_role": "Customer"},
  "zh-CN": {"title": "点咖啡", "description": "在咖啡店点一杯咖啡", "goal": "成功点一杯咖啡", "initial_message": "你好！今天想喝点什么？", "ai_role": "咖啡师", "user_role": "顾客"},
  "ja-JP": {"title": "コーヒーを注文する", "description": "カフェでコーヒーを注文する", "goal": "コーヒーを注文する", "initial_message": "いらっしゃいませ！ご注文はお決まりですか？", "ai_role": "バリスタ", "user_role": "お客様"},
  "ko-KR": {"title": "커피 주문하기", "description": "카페에서 커피를 주문하세요", "goal": "커피를 성공적으로 주문하세요", "initial_message": "안녕하세요! 무엇을 드릴까요?", "ai_role": "바리스타", "user_role": "손님"},
  "es-ES": {"title": "Pedir un café", "description": "Pide un café en una cafetería", "goal": "Pedir un café", "initial_message": "¡Hola! ¿Qué le pongo hoy?", "ai_role": "Barista", "user_role": "Cliente"},
  "es-MX": {"title": "Pedir un café", "description": "Ordena un café", "goal": "Logra pedir tu café", "initial_message": "¡Hola! ¿Qué le sirvo hoy?", "ai_role": "Barista", "user_role": "Cliente"},
  "fr-FR": {"title": "Commander un café", "description": "Commandez un café dans un café", "goal": "Commander un café", "initial_message": "Bonjour ! Que puis-je vous servir ?", "ai_role": "Barista", "user_role": "Client"},
  "de-DE": {"title": "Kaffee bestellen", "description": "Bestellen Sie einen Kaffee", "goal": "Einen Kaffee bestellen", "initial_message": "Hallo! Was darf es sein?", "ai_role": "Barista", "user_role": "Kunde"}
}'::jsonb WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- 2. Check-in at Immigration (b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Immigration Check", "description": "Answer questions and pass through immigration", "goal": "Successfully pass immigration", "initial_message": "Good morning. May I see your passport?", "ai_role": "Immigration Officer", "user_role": "Traveler"},
  "en-GB": {"title": "Immigration Check", "description": "Answer questions and pass through immigration", "goal": "Successfully pass immigration", "initial_message": "Good morning. May I see your passport, please?", "ai_role": "Immigration Officer", "user_role": "Traveller"},
  "zh-CN": {"title": "入境检查", "description": "回答问题并通过入境检查", "goal": "回答问题并通过入境检查", "initial_message": "早上好，请出示您的护照。", "ai_role": "入境官员", "user_role": "旅客"},
  "ja-JP": {"title": "入国審査", "description": "質問に答えて入国審査を通過する", "goal": "質問に答えて入国審査を通過する", "initial_message": "おはようございます。パスポートを見せていただけますか？", "ai_role": "入国審査官", "user_role": "旅行者"},
  "ko-KR": {"title": "입국 심사", "description": "질문에 대답하고 입국 심사를 통과하세요", "goal": "질문에 대답하고 입국 심사를 통과하세요", "initial_message": "안녕하세요. 여권을 보여주시겠어요?", "ai_role": "출입국 심사관", "user_role": "여행자"},
  "es-ES": {"title": "Control de inmigración", "description": "Responde a las preguntas y pasa el control", "goal": "Pasar el control de inmigración", "initial_message": "Buenos días. ¿Puedo ver su pasaporte?", "ai_role": "Agente de inmigración", "user_role": "Viajero"},
  "es-MX": {"title": "Migración", "description": "Contesta preguntas en migración", "goal": "Pasa los filtros de migración", "initial_message": "Buenos días. ¿Me permite su pasaporte?", "ai_role": "Oficial de migración", "user_role": "Viajero"},
  "fr-FR": {"title": "Contrôle d''immigration", "description": "Répondez aux questions et passez l''immigration", "goal": "Franchir l''immigration", "initial_message": "Bonjour. Puis-je voir votre passeport ?", "ai_role": "Agent d''immigration", "user_role": "Voyageur"},
  "de-DE": {"title": "Einreisekontrolle", "description": "Fragen beantworten und die Kontrolle passieren", "goal": "Einreisekontrolle passieren", "initial_message": "Guten Morgen. Darf ich Ihren Reisepass sehen?", "ai_role": "Grenzbeamter", "user_role": "Reisender"}
}'::jsonb WHERE id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12';

-- 3. Lost Wallet (c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Lost Wallet", "description": "Ask for help finding your wallet", "goal": "Ask for help finding your wallet", "initial_message": "Excuse me, you look worried. Is everything okay?", "ai_role": "Helpful Stranger", "user_role": "Person who lost wallet"},
  "en-GB": {"title": "Lost Wallet", "description": "Ask for help finding your wallet", "goal": "Ask for help finding your wallet", "initial_message": "Pardon me, you look troubled. Is everything alright?", "ai_role": "Helpful Stranger", "user_role": "Person who lost wallet"},
  "zh-CN": {"title": "丢了钱包", "description": "寻求帮助找回钱包", "goal": "寻求帮助找回钱包", "initial_message": "打扰一下，你看起来很着急，有什么问题吗？", "ai_role": "热心路人", "user_role": "丢失钱包的人"},
  "ja-JP": {"title": "財布をなくした", "description": "財布を見つけるために助けを求める", "goal": "財布を見つけるために助けを求める", "initial_message": "すみません、困っているようですね。大丈夫ですか？", "ai_role": "親切な人", "user_role": "財布をなくした人"},
  "ko-KR": {"title": "지갑 분실", "description": "지갑을 찾는 데 도움을 요청하세요", "goal": "지갑을 찾는 데 도움을 요청하세요", "initial_message": "실례합니다, 걱정되어 보이시네요. 괜찮으세요?", "ai_role": "친절한 행인", "user_role": "지갑을 잃어버린 사람"},
  "es-ES": {"title": "Cartera perdida", "description": "Pide ayuda para encontrar tu cartera", "goal": "Pedir ayuda para recuperar la cartera", "initial_message": "Disculpe, parece preocupado. ¿Está todo bien?", "ai_role": "Extraño servicial", "user_role": "Persona que perdió la cartera"},
  "es-MX": {"title": "Cartera perdida", "description": "Pide ayuda para encontrar tu cartera", "goal": "Pedir ayuda para encontrar la cartera", "initial_message": "Disculpe, se ve preocupado. ¿Todo bien?", "ai_role": "Persona amable", "user_role": "Persona que perdió la cartera"},
  "fr-FR": {"title": "Porte-monnaie perdu", "description": "Demandez de l''aide pour retrouver votre porte-monnaie", "goal": "Retrouver votre porte-monnaie", "initial_message": "Excusez-moi, vous semblez inquiet. Tout va bien ?", "ai_role": "Inconnu serviable", "user_role": "Personne ayant perdu son portefeuille"},
  "de-DE": {"title": "Geldbörse verloren", "description": "Bitten Sie um Hilfe, Ihre Geldbörse zu finden", "goal": "Um Hilfe bitten", "initial_message": "Entschuldigung, Sie sehen besorgt aus. Ist alles in Ordnung?", "ai_role": "Hilfsbereiter Fremder", "user_role": "Person, die Geldbörse verloren hat"}
}'::jsonb WHERE id = 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13';

-- 4. Taking a Taxi (d3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Taking a Taxi", "description": "Give directions to the driver", "goal": "Reach your destination", "initial_message": "Hello! Where are you heading to today?", "ai_role": "Taxi Driver", "user_role": "Passenger"},
  "en-GB": {"title": "Taking a Taxi", "description": "Give directions to the driver", "goal": "Reach your destination", "initial_message": "Hello! Where would you like to go?", "ai_role": "Taxi Driver", "user_role": "Passenger"},
  "zh-CN": {"title": "乘坐出租车", "description": "给司机指路", "goal": "到达目的地", "initial_message": "你好！请问去哪里？", "ai_role": "出租车司机", "user_role": "乘客"},
  "ja-JP": {"title": "タクシーに乗る", "description": "運転手に行き先を告げる", "goal": "目的地に到着する", "initial_message": "こんにちは！どちらまで行かれますか？", "ai_role": "タクシー運転手", "user_role": "乗客"},
  "ko-KR": {"title": "택시 타기", "description": "기사에게 길 안내하기", "goal": "목적지에 도착하세요", "initial_message": "안녕하세요! 어디로 가실 건가요?", "ai_role": "택시 기사", "user_role": "승객"},
  "es-ES": {"title": "Coger un taxi", "description": "Da indicaciones al conductor", "goal": "Llegar a tu destino", "initial_message": "¡Hola! ¿Adónde le llevo?", "ai_role": "Taxista", "user_role": "Pasajero"},
  "es-MX": {"title": "Tomar un taxi", "description": "Dale indicaciones al chofer", "goal": "Llegar a tu destino", "initial_message": "¡Hola! ¿A dónde lo llevo?", "ai_role": "Taxista", "user_role": "Pasajero"},
  "fr-FR": {"title": "Prendre un taxi", "description": "Donnez des indications au chauffeur", "goal": "Arriver à destination", "initial_message": "Bonjour ! Où allez-vous ?", "ai_role": "Chauffeur de taxi", "user_role": "Passager"},
  "de-DE": {"title": "Taxi fahren", "description": "Geben Sie dem Fahrer Anweisungen", "goal": "Das Ziel erreichen", "initial_message": "Hallo! Wohin soll es gehen?", "ai_role": "Taxifahrer", "user_role": "Fahrgast"}
}'::jsonb WHERE id = 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14';

-- 5. Supermarket Shopping (e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Supermarket Shopping", "description": "Ask where to find items", "goal": "Find all items on your list", "initial_message": "Hi there! Can I help you find anything?", "ai_role": "Supermarket Staff", "user_role": "Customer"},
  "en-GB": {"title": "Supermarket Shopping", "description": "Ask where to find items", "goal": "Find all items on your list", "initial_message": "Hello! Can I help you find something?", "ai_role": "Supermarket Staff", "user_role": "Customer"},
  "zh-CN": {"title": "超市购物", "description": "询问商品位置", "goal": "找到清单上的所有商品", "initial_message": "你好！需要帮忙找什么吗？", "ai_role": "超市店员", "user_role": "顾客"},
  "ja-JP": {"title": "スーパーで買い物", "description": "商品の場所を尋ねる", "goal": "リストにある商品をすべて見つける", "initial_message": "いらっしゃいませ！何かお探しですか？", "ai_role": "スーパーの店員", "user_role": "お客様"},
  "ko-KR": {"title": "슈퍼마켓 쇼핑", "description": "물건 위치 물어보기", "goal": "쇼핑 목록에 있는 모든 물건 찾기", "initial_message": "안녕하세요! 뭔가 찾으시나요?", "ai_role": "슈퍼마켓 직원", "user_role": "손님"},
  "es-ES": {"title": "En el supermercado", "description": "Pregunta dónde están los productos", "goal": "Encontrar todo lo de la lista", "initial_message": "¡Hola! ¿Puedo ayudarle a encontrar algo?", "ai_role": "Empleado del supermercado", "user_role": "Cliente"},
  "es-MX": {"title": "En el súper", "description": "Pregunta por los pasillos", "goal": "Encontrar tus recados", "initial_message": "¡Hola! ¿Le ayudo a buscar algo?", "ai_role": "Empleado del súper", "user_role": "Cliente"},
  "fr-FR": {"title": "Courses au supermarché", "description": "Demandez où trouver des articles", "goal": "Trouver tous les articles", "initial_message": "Bonjour ! Puis-je vous aider à trouver quelque chose ?", "ai_role": "Employé du supermarché", "user_role": "Client"},
  "de-DE": {"title": "Einkaufen im Supermarkt", "description": "Fragen Sie, wo Artikel zu finden sind", "goal": "Alle Artikel finden", "initial_message": "Hallo! Kann ich Ihnen helfen, etwas zu finden?", "ai_role": "Supermarkt-Mitarbeiter", "user_role": "Kunde"}
}'::jsonb WHERE id = 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15';

-- 6. Asking for Directions (f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a16)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Asking for Directions", "description": "Ask a local for directions", "goal": "Find the way to your destination", "initial_message": "Hello! Do you need some help finding your way?", "ai_role": "Local", "user_role": "Lost Traveler"},
  "en-GB": {"title": "Asking for Directions", "description": "Ask a local for directions", "goal": "Find the way to your destination", "initial_message": "Hello! Are you looking for somewhere?", "ai_role": "Local", "user_role": "Lost Traveller"},
  "zh-CN": {"title": "问路", "description": "向当地人问路", "goal": "找到去目的地的路", "initial_message": "你好！需要帮忙指路吗？", "ai_role": "当地人", "user_role": "迷路的旅客"},
  "ja-JP": {"title": "道を尋ねる", "description": "地元の人に道を尋ねる", "goal": "目的地への行き方を見つける", "initial_message": "こんにちは！道をお探しですか？", "ai_role": "地元の人", "user_role": "道に迷った旅行者"},
  "ko-KR": {"title": "길 묻기", "description": "현지인에게 길 물어보기", "goal": "목적지로 가는 길 찾기", "initial_message": "안녕하세요! 길을 찾고 계신가요?", "ai_role": "현지인", "user_role": "길 잃은 여행자"},
  "es-ES": {"title": "Preguntar direcciones", "description": "Pregunta a un local por una dirección", "goal": "Encontrar el camino", "initial_message": "¡Hola! ¿Necesita ayuda para encontrar algo?", "ai_role": "Lugareño", "user_role": "Viajero perdido"},
  "es-MX": {"title": "Preguntar direcciones", "description": "Pregunta cómo llegar", "goal": "Encontrar la ruta", "initial_message": "¡Hola! ¿Anda perdido?", "ai_role": "Lugareño", "user_role": "Viajero perdido"},
  "fr-FR": {"title": "Demander son chemin", "description": "Demandez votre chemin à un local", "goal": "Trouver votre destination", "initial_message": "Bonjour ! Vous cherchez votre chemin ?", "ai_role": "Habitant local", "user_role": "Voyageur perdu"},
  "de-DE": {"title": "Nach dem Weg fragen", "description": "Fragen Sie einen Einheimischen nach dem Weg", "goal": "Den Weg finden", "initial_message": "Hallo! Suchen Sie etwas Bestimmtes?", "ai_role": "Einheimischer", "user_role": "Verirrter Reisender"}
}'::jsonb WHERE id = 'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a16';

-- 7. First Meeting (06eebc99-9c0b-4ef8-bb6d-6bb9bd380a17)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "First Meeting", "description": "Introduce yourself to a new friend", "goal": "Get to know each other", "initial_message": "Hi! Nice to meet you. I''m Alex.", "ai_role": "New Friend", "user_role": "Self"},
  "en-GB": {"title": "First Meeting", "description": "Introduce yourself to a new friend", "goal": "Get to know each other", "initial_message": "Hello! Lovely to meet you. I''m Alex.", "ai_role": "New Friend", "user_role": "Self"},
  "zh-CN": {"title": "初次见面", "description": "向新朋友介绍自己", "goal": "互相了解", "initial_message": "嗨！很高兴认识你，我叫小明。", "ai_role": "新朋友", "user_role": "自己"},
  "ja-JP": {"title": "初対面", "description": "新しい友達に自己紹介する", "goal": "お互いを知る", "initial_message": "こんにちは！はじめまして、私はアレックスです。", "ai_role": "新しい友達", "user_role": "自分"},
  "ko-KR": {"title": "첫 만남", "description": "새 친구에게 자기 소개하기", "goal": "서로 알아가기", "initial_message": "안녕하세요! 만나서 반가워요. 저는 민수예요.", "ai_role": "새 친구", "user_role": "나"},
  "es-ES": {"title": "Primera cita", "description": "Preséntate a un nuevo amigo", "goal": "Conocerse mutuamente", "initial_message": "¡Hola! Encantado de conocerte. Soy Alejandro.", "ai_role": "Nuevo amigo", "user_role": "Tú mismo"},
  "es-MX": {"title": "Conociendo a alguien", "description": "Preséntate con un amigo nuevo", "goal": "Conocerse", "initial_message": "¡Hola! Mucho gusto. Me llamo Alejandro.", "ai_role": "Nuevo amigo", "user_role": "Tú mismo"},
  "fr-FR": {"title": "Première rencontre", "description": "Presentez-vous à un nouvel ami", "goal": "Apprendre à se connaître", "initial_message": "Salut ! Enchanté de te rencontrer. Je suis Alex.", "ai_role": "Nouvel ami", "user_role": "Soi-même"},
  "de-DE": {"title": "Erstes Treffen", "description": "Stellen Sie sich einem neuen Freund vor", "goal": "Sich kennenlernen", "initial_message": "Hallo! Freut mich, dich kennenzulernen. Ich bin Alex.", "ai_role": "Neuer Freund", "user_role": "Du selbst"}
}'::jsonb WHERE id = '06eebc99-9c0b-4ef8-bb6d-6bb9bd380a17';

-- 8. Hotel Check-in (17eebc99-9c0b-4ef8-bb6d-6bb9bd380a18)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Hotel Check-in", "description": "Check in to your hotel room", "goal": "Successfully check in", "initial_message": "Welcome! Do you have a reservation with us?", "ai_role": "Receptionist", "user_role": "Guest"},
  "en-GB": {"title": "Hotel Check-in", "description": "Check in to your hotel room", "goal": "Successfully check in", "initial_message": "Welcome! Have you got a reservation with us?", "ai_role": "Receptionist", "user_role": "Guest"},
  "zh-CN": {"title": "酒店入住", "description": "办理酒店入住手续", "goal": "成功办理入住", "initial_message": "欢迎光临！请问您有预订吗？", "ai_role": "前台接待", "user_role": "客人"},
  "ja-JP": {"title": "ホテルのチェックイン", "description": "ホテルの部屋にチェックインする", "goal": "チェックインを完了する", "initial_message": "いらっしゃいませ！ご予約はございますか？", "ai_role": "フロント係", "user_role": "お客様"},
  "ko-KR": {"title": "호텔 체크인", "description": "호텔 객실 체크인하기", "goal": "체크인 성공하기", "initial_message": "환영합니다! 예약하셨나요?", "ai_role": "프런트 직원", "user_role": "손님"},
  "es-ES": {"title": "Check-in en hotel", "description": "Regístrate en tu hotel", "goal": "Hacer el check-in", "initial_message": "¡Bienvenido! ¿Tiene reserva con nosotros?", "ai_role": "Recepcionista", "user_role": "Huésped"},
  "es-MX": {"title": "Check-in en hotel", "description": "Regístrate en el hotel", "goal": "Hacer el check-in", "initial_message": "¡Bienvenido! ¿Tiene reservación?", "ai_role": "Recepcionista", "user_role": "Huésped"},
  "fr-FR": {"title": "Check-in à l''hôtel", "description": "Enregistrez-vous à l''hôtel", "goal": "Réussir l''enregistrement", "initial_message": "Bienvenue ! Avez-vous une réservation ?", "ai_role": "Réceptionniste", "user_role": "Client"},
  "de-DE": {"title": "Hotel Check-in", "description": "Checken Sie in Ihr Hotelzimmer ein", "goal": "Erfolgreich einchecken", "initial_message": "Willkommen! Haben Sie eine Reservierung?", "ai_role": "Rezeptionist", "user_role": "Gast"}
}'::jsonb WHERE id = '17eebc99-9c0b-4ef8-bb6d-6bb9bd380a18';

-- 9. Restaurant Ordering (28eebc99-9c0b-4ef8-bb6d-6bb9bd380a19)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Restaurant Ordering", "description": "Order food at a restaurant", "goal": "Order your meal", "initial_message": "Good evening. Here is the menu. Are you ready to order?", "ai_role": "Waiter", "user_role": "Customer"},
  "en-GB": {"title": "Restaurant Ordering", "description": "Order food at a restaurant", "goal": "Order your meal", "initial_message": "Good evening. Here is the menu. Are you ready to order?", "ai_role": "Waiter", "user_role": "Customer"},
  "zh-CN": {"title": "餐厅点餐", "description": "在餐厅点菜", "goal": "点餐", "initial_message": "晚上好，这是菜单。请问您准备好点餐了吗？", "ai_role": "服务员", "user_role": "顾客"},
  "ja-JP": {"title": "レストランで注文", "description": "レストランで食事を注文する", "goal": "食事を注文する", "initial_message": "こんばんは。こちらがメニューです。ご注文はお決まりですか？", "ai_role": "ウェイター", "user_role": "お客様"},
  "ko-KR": {"title": "식당 주문", "description": "식당에서 음식 주문하기", "goal": "식사 주문하기", "initial_message": "안녕하세요. 메뉴판입니다. 주문하시겠어요?", "ai_role": "웨이터", "user_role": "손님"},
  "es-ES": {"title": "Pedir en restaurante", "description": "Pide comida en un restaurante", "goal": "Pedir la comida", "initial_message": "Buenas noches. Aquí tiene la carta. ¿Está listo para pedir?", "ai_role": "Camarero", "user_role": "Cliente"},
  "es-MX": {"title": "Pedir comida", "description": "Ordena en un restaurante", "goal": "Pedir tus alimentos", "initial_message": "Buenas noches. Aquí tiene el menú. ¿Ya sabe qué va a ordenar?", "ai_role": "Mesero", "user_role": "Cliente"},
  "fr-FR": {"title": "Commander au restaurant", "description": "Commandez un repas", "goal": "Commander votre repas", "initial_message": "Bonsoir. Voici le menu. Êtes-vous prêt à commander ?", "ai_role": "Serveur", "user_role": "Client"},
  "de-DE": {"title": "Im Restaurant bestellen", "description": "Bestellen Sie Essen im Restaurant", "goal": "Mahlzeit bestellen", "initial_message": "Guten Abend. Hier ist die Speisekarte. Sind Sie bereit zu bestellen?", "ai_role": "Kellner", "user_role": "Kunde"}
}'::jsonb WHERE id = '28eebc99-9c0b-4ef8-bb6d-6bb9bd380a19';

-- 10. Job Interview (39eebc99-9c0b-4ef8-bb6d-6bb9bd380a20)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Job Interview", "description": "Answer interview questions", "goal": "Impress the interviewer", "initial_message": "Thank you for coming in through. Tell me a bit about yourself.", "ai_role": "Interviewer", "user_role": "Candidate"},
  "en-GB": {"title": "Job Interview", "description": "Answer interview questions", "goal": "Impress the interviewer", "initial_message": "Thank you for coming in. Tell me a bit about yourself.", "ai_role": "Interviewer", "user_role": "Candidate"},
  "zh-CN": {"title": "求职面试", "description": "回答面试问题", "goal": "给面试官留下好印象", "initial_message": "感谢您来参加面试。请先简单介绍一下自己。", "ai_role": "面试官", "user_role": "求职者"},
  "ja-JP": {"title": "就職面接", "description": "面接の質問に答える", "goal": "面接官に好印象を与える", "initial_message": "本日はお越しいただきありがとうございます。まず自己紹介をお願いします。", "ai_role": "面接官", "user_role": "応募者"},
  "ko-KR": {"title": "취업 면접", "description": "면접 질문에 대답하기", "goal": "면접관에게 좋은 인상 남기기", "initial_message": "와주셔서 감사합니다. 간단한 자기소개 부탁드립니다.", "ai_role": "면접관", "user_role": "지원자"},
  "es-ES": {"title": "Entrevista de trabajo", "description": "Responde preguntas de la entrevista", "goal": "Impresionar al entrevistador", "initial_message": "Gracias por venir. Cuénteme un poco sobre usted.", "ai_role": "Entrevistador", "user_role": "Candidato"},
  "es-MX": {"title": "Entrevista de trabajo", "description": "Contesta preguntas de entrevista", "goal": "Dar una buena impresión", "initial_message": "Gracias por venir. Platíqueme un poco de usted.", "ai_role": "Entrevistador", "user_role": "Candidato"},
  "fr-FR": {"title": "Entretien d''embauche", "description": "Répondez aux questions d''entretien", "goal": "Impressionner le recruteur", "initial_message": "Merci d''être venu. Parlez-moi un peu de vous.", "ai_role": "Recruteur", "user_role": "Candidat"},
  "de-DE": {"title": "Vorstellungsgespräch", "description": "Beantworten Sie Bewerbungsfragen", "goal": "Den Interviewer beeindrucken", "initial_message": "Danke, dass Sie gekommen sind. Erzählen Sie mir etwas über sich.", "ai_role": "Interviewer", "user_role": "Bewerber"}
}'::jsonb WHERE id = '39eebc99-9c0b-4ef8-bb6d-6bb9bd380a20';

-- 11. Business Meeting (4aeebc99-9c0b-4ef8-bb6d-6bb9bd380a21)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Business Meeting", "description": "Discuss a project with colleagues", "goal": "Coordinate the project next steps", "initial_message": "Shall we get started with the project update?", "ai_role": "Colleague", "user_role": "Project Manager"},
  "en-GB": {"title": "Business Meeting", "description": "Discuss a project with colleagues", "goal": "Coordinate the project next steps", "initial_message": "Shall we get started with the project update?", "ai_role": "Colleague", "user_role": "Project Manager"},
  "zh-CN": {"title": "商务会议", "description": "与同事讨论项目", "goal": "协调项目后续步骤", "initial_message": "我们开始项目进度汇报吧？", "ai_role": "同事", "user_role": "项目经理"},
  "ja-JP": {"title": "ビジネス会議", "description": "同僚とプロジェクトについて話し合う", "goal": "プロジェクトの次のステップを調整する", "initial_message": "それでは、プロジェクトの進捗報告を始めましょうか？", "ai_role": "同僚", "user_role": "プロジェクトマネージャー"},
  "ko-KR": {"title": "비즈니스 회의", "description": "동료와 프로젝트 논의하기", "goal": "프로젝트 다음 단계 조정하기", "initial_message": "프로젝트 업데이트를 시작할까요?", "ai_role": "동료", "user_role": "프로젝트 매니저"},
  "es-ES": {"title": "Reunión de negocios", "description": "Discute un proyecto con colegas", "goal": "Coordinar siguientes pasos", "initial_message": "¿Empezamos con la actualización del proyecto?", "ai_role": "Colega", "user_role": "Director de proyecto"},
  "es-MX": {"title": "Junta de trabajo", "description": "Discute proyectos con colegas", "goal": "Acordar los siguientes pasos", "initial_message": "¿Comenzamos con la actualización del proyecto?", "ai_role": "Colega", "user_role": "Gerente de proyecto"},
  "fr-FR": {"title": "Réunion d''affaires", "description": "Discutez d''un projet avec des collègues", "goal": "Coordonner les prochaines étapes", "initial_message": "On commence le point sur le projet ?", "ai_role": "Collègue", "user_role": "Chef de projet"},
  "de-DE": {"title": "Geschäftsmeeting", "description": "Besprechen Sie ein Projekt mit Kollegen", "goal": "Nächste Schritte koordinieren", "initial_message": "Sollen wir mit dem Projekt-Update beginnen?", "ai_role": "Kollege", "user_role": "Projektleiter"}
}'::jsonb WHERE id = '4aeebc99-9c0b-4ef8-bb6d-6bb9bd380a21';

-- 12. Movie Discussion (5beebc99-9c0b-4ef8-bb6d-6bb9bd380a22)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Movie Discussion", "description": "Talk about a movie you saw", "goal": "Share opinions about the movie", "initial_message": "I just saw that new movie everyone is talking about! Have you seen it?", "ai_role": "Friend", "user_role": "Self"},
  "en-GB": {"title": "Movie Discussion", "description": "Talk about a movie you saw", "goal": "Share opinions about the movie", "initial_message": "I just saw that new film everyone is talking about! Have you seen it?", "ai_role": "Friend", "user_role": "Self"},
  "zh-CN": {"title": "电影讨论", "description": "谈论你看过的一部电影", "goal": "分享对电影的看法", "initial_message": "我刚看了那部大家都在讨论的新电影！你看过了吗？", "ai_role": "朋友", "user_role": "自己"},
  "ja-JP": {"title": "映画の話", "description": "見た映画について話す", "goal": "映画の感想を共有する", "initial_message": "話題の新作映画を見てきたよ！もう見た？", "ai_role": "友達", "user_role": "自分"},
  "ko-KR": {"title": "영화 토론", "description": "본 영화에 대해 이야기하기", "goal": "영화에 대한 의견 공유하기", "initial_message": "요즘 화제되는 새 영화 봤어! 너도 봤어?", "ai_role": "친구", "user_role": "나"},
  "es-ES": {"title": "Hablar de cine", "description": "Habla sobre una película que viste", "goal": "Compartir opiniones", "initial_message": "¡Acabo de ver esa película de la que todos hablan! ¿La has visto?", "ai_role": "Amigo", "user_role": "Tú mismo"},
  "es-MX": {"title": "Plática de cine", "description": "Platica sobre una película", "goal": "Compartir opiniones", "initial_message": "¡Acabo de ver esa película de la que todos hablan! ¿Ya la viste?", "ai_role": "Amigo", "user_role": "Tú mismo"},
  "fr-FR": {"title": "Discussion sur un film", "description": "Parlez d''un film que vous avez vu", "goal": "Partager des opinions", "initial_message": "Je viens de voir ce nouveau film dont tout le monde parle ! Tu l''as vu ?", "ai_role": "Ami", "user_role": "Soi-même"},
  "de-DE": {"title": "Über Filme sprechen", "description": "Sprechen Sie über einen Film", "goal": "Meinungen austauschen", "initial_message": "Ich habe gerade den neuen Film gesehen, über den alle reden! Hast du ihn gesehen?", "ai_role": "Freund", "user_role": "Du selbst"}
}'::jsonb WHERE id = '5beebc99-9c0b-4ef8-bb6d-6bb9bd380a22';

-- 13. Seeing a Doctor (6ceebc99-9c0b-4ef8-bb6d-6bb9bd380a23)
UPDATE standard_scenes SET translations = '{
  "en-US": {"title": "Seeing a Doctor", "description": "Describe your symptoms to a doctor", "goal": "Explain your symptoms and get advice", "initial_message": "Hello. What seems to be the trouble today?", "ai_role": "Doctor", "user_role": "Patient"},
  "en-GB": {"title": "Seeing a Doctor", "description": "Describe your symptoms to a doctor", "goal": "Explain your symptoms and get advice", "initial_message": "Hello. What seems to be the trouble today?", "ai_role": "Doctor", "user_role": "Patient"},
  "zh-CN": {"title": "看医生", "description": "向医生描述症状", "goal": "解释症状并获取建议", "initial_message": "你好，今天哪里不舒服？", "ai_role": "医生", "user_role": "患者"},
  "ja-JP": {"title": "医者にかかる", "description": "医者に症状を説明する", "goal": "症状を説明してアドバイスをもらう", "initial_message": "こんにちは。今日はどうされましたか？", "ai_role": "医師", "user_role": "患者"},
  "ko-KR": {"title": "병원 진료", "description": "의사에게 증상 설명하기", "goal": "증상을 설명하고 조언 구하기", "initial_message": "안녕하세요. 오늘 어디가 불편하세요?", "ai_role": "의사", "user_role": "환자"},
  "es-ES": {"title": "Ir al médico", "description": "Describe tus síntomas al doctor", "goal": "Explicar síntomas y recibir consejo", "initial_message": "Hola. ¿Qué le pasa hoy?", "ai_role": "Doctor", "user_role": "Paciente"},
  "es-MX": {"title": "Ir al doctor", "description": "Describe tus síntomas", "goal": "Obtener diagnóstico y consejo", "initial_message": "Hola. ¿Qué lo trae por aquí hoy?", "ai_role": "Doctor", "user_role": "Paciente"},
  "fr-FR": {"title": "Aller chez le médecin", "description": "Décrivez vos symptômes au médecin", "goal": "Expliquer les symptômes", "initial_message": "Bonjour. Qu''est-ce qui vous amène aujourd''hui ?", "ai_role": "Médecin", "user_role": "Patient"},
  "de-DE": {"title": "Arztbesuch", "description": "Beschreiben Sie Ihre Symptome", "goal": "Rat einholen", "initial_message": "Hallo. Was führt Sie heute zu mir?", "ai_role": "Arzt", "user_role": "Patient"}
}'::jsonb WHERE id = '6ceebc99-9c0b-4ef8-bb6d-6bb9bd380a23';


-- ============================================
-- Step 2: Update scene generation trigger with correct localization logic
-- ============================================
-- Key changes:
-- ALL fields (title, description, goal, initial_message, ai_role, user_role) 
-- now use target_lang (the language user is learning)
-- This provides a fully immersive experience in the target language

CREATE OR REPLACE FUNCTION handle_user_scene_generation()
RETURNS TRIGGER AS $$
BEGIN
  -- Guard 1: target_lang must be set
  IF NEW.target_lang IS NULL THEN
    RETURN NEW;
  END IF;

  -- Guard 2: On UPDATE, only proceed if target_lang actually changed
  IF TG_OP = 'UPDATE' AND OLD.target_lang IS NOT DISTINCT FROM NEW.target_lang THEN
    RETURN NEW;
  END IF;

  -- Guard 3: If user already has scenes, skip (only generate during Onboarding)
  -- This ensures Profile page language changes do NOT regenerate scenes
  IF EXISTS (SELECT 1 FROM custom_scenarios WHERE user_id = NEW.id LIMIT 1) THEN
    RETURN NEW;
  END IF;

  -- Insert scenes with full target_lang localization:
  -- ALL fields use target_lang (the language user is learning)
  -- Fallback to en-US if target_lang translation is not available
  INSERT INTO custom_scenarios (
    user_id, title, description, ai_role, user_role, initial_message,
    goal, emoji, category, difficulty, icon_path, color,
    target_language, origin_standard_id, source_type, updated_at
  )
  SELECT
    NEW.id,
    -- 1. Title: Use target_lang -> fallback en-US
    COALESCE(
      s.translations -> NEW.target_lang ->> 'title',
      s.translations -> 'en-US' ->> 'title'
    ),
    -- 2. Description: Use target_lang -> fallback en-US
    COALESCE(
      s.translations -> NEW.target_lang ->> 'description',
      s.translations -> 'en-US' ->> 'description'
    ),
    -- 3. AI Role: Use target_lang -> fallback en-US
    COALESCE(
      s.translations -> NEW.target_lang ->> 'ai_role',
      s.translations -> 'en-US' ->> 'ai_role'
    ),
    -- 4. User Role: Use target_lang -> fallback en-US
    COALESCE(
      s.translations -> NEW.target_lang ->> 'user_role',
      s.translations -> 'en-US' ->> 'user_role'
    ),
    -- 5. Initial Message: Use target_lang -> fallback en-US
    COALESCE(
      s.translations -> NEW.target_lang ->> 'initial_message',
      s.translations -> 'en-US' ->> 'initial_message'
    ),
    -- 6. Goal: Use target_lang -> fallback en-US
    COALESCE(
      s.translations -> NEW.target_lang ->> 'goal',
      s.translations -> 'en-US' ->> 'goal'
    ),
    s.emoji,
    s.category,
    s.difficulty,
    s.icon_path,
    s.color,
    -- FORCE target_language to be the USER's target language
    NEW.target_lang,
    s.id,
    'standard',
    NOW() - (ROW_NUMBER() OVER (ORDER BY s.id) * INTERVAL '1 second')
  FROM standard_scenes s
  WHERE s.target_language = NEW.target_lang
     OR (
       -- Fallback logic: If no scenes exist for this target language, use English scenes
       NOT EXISTS (SELECT 1 FROM standard_scenes WHERE target_language = NEW.target_lang)
       AND s.target_language = 'en-US'
     )
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================
-- Step 3: Remove redundant columns from standard_scenes
-- ============================================
-- All content now comes from translations JSONB, making these columns obsolete.
-- We keep: id, emoji, category, difficulty, icon_path, color, target_language, created_at, translations

ALTER TABLE standard_scenes
  DROP COLUMN IF EXISTS title,
  DROP COLUMN IF EXISTS description,
  DROP COLUMN IF EXISTS initial_message,
  DROP COLUMN IF EXISTS goal,
  DROP COLUMN IF EXISTS ai_role,
  DROP COLUMN IF EXISTS user_role;

-- Ensure translations column is NOT NULL and contains required data
ALTER TABLE standard_scenes
  ALTER COLUMN translations SET NOT NULL;

-- Update the comment to reflect the new schema
COMMENT ON TABLE standard_scenes IS 
  'Seed library of standard scenes. All text content is stored in translations JSONB with en-US as fallback.';

COMMENT ON COLUMN standard_scenes.translations IS 
  'Localized content for all text fields. Required keys per language: title, description, goal, initial_message, ai_role, user_role. en-US is mandatory as fallback.';
