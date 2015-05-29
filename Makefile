-include config.mk

Sources = $(shell find . -name '*.lua' -or \
                         -name '*.png' -or \
                         -name '*.ogg')

LittleTanks.love: $(Sources)
	zip -X $@ $^

test:
	luacheck .

deploy: LittleTanks.love
	scp LittleTanks.love $(DEPLOY_TARGET)

clean:
	rm -vf LittleTanks.love

.PHONY: test deploy clean
